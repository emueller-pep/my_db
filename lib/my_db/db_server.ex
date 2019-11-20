defmodule MyDb.DbServer do
  @moduledoc """
  Write a database server that stores a database in its loop data. You should register the server
  and access its services through a functional interface. Exported functions should include:

  MyDb.DbServer.start() → :ok
  MyDb.DbServer.stop() → :ok
  MyDb.DbServer.write(key, element) → :ok
  MyDb.DbServer.delete(key) → :ok
  MyDb.DbServer.read(key) → {:ok, element} | {:error, :instance}
  MyDb.DbServer.match(element) → [key1, ..., keyn]
  """

  def start() do
    pid = spawn(MyDb.DbServer, :init, [])
    Process.register(pid, MyDb.DbServer)
    :ok
  end

  def stop() do
    send(MyDb.DbServer, { :destroy })
    :ok
  end

  def write(key, value) do call({ :write, key, value }) end
  def delete(key) do call({ :delete, key }) end
  def read(key) do call({ :read, key }) end
  def match(value) do call({ :match, value }) end
  def records() do call({ :records }) end
  def lock() do call({ :lock }) end
  def unlock() do call({ :unlock }) end

  defp call(message) do
    send(MyDb.DbServer, { :request, self(), message })
    receive do
      { :reply, reply } -> reply
    end
  end

  # not actually public
  def init() do unlocked_loop(MyDb.Backends.ListDb.new) end

  defp unlocked_loop(db) do
    receive do
      { :destroy } -> MyDb.Backends.ListDb.destroy(db); :ok
      { :request, from, { :lock } } -> 
        send(from, { :reply, :ok })
        locked_loop(db, from)
      { :request, from, message } ->
        unlocked_loop(handle_request(db, from, message))
    end
  end

  defp locked_loop(db, from) do
    receive do
      { :request, ^from, { :unlock } } ->
        send(from, { :reply, :ok })
        unlocked_loop(db)
      { :request, ^from, message } ->
        locked_loop(handle_request(db, from, message), from)
    end
  end

  defp handle_request(db, from, message) do
    case message do
      { :write, key, value } ->
        db = MyDb.Backends.ListDb.write(db, key, value)
        send(from, { :reply, :ok })
        db
      { :read, key } ->
        result = MyDb.Backends.ListDb.read(db, key)
        send(from, { :reply, result })
        db
      { :delete, key } ->
        db = MyDb.Backends.ListDb.delete(db, key)
        send(from, { :reply, :ok })
        db
      { :match, value } ->
        results = MyDb.Backends.ListDb.match(db, value)
        send(from, { :reply, results })
        db
      { :records } ->
        results = MyDb.Backends.ListDb.records(db)
        send(from, { :reply, results })
        db
    end
  end
end
