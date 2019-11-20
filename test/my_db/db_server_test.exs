defmodule MyDb.DbServerTest do
  alias MyDb.DbServer, as: Server
  use ExUnit.Case, async: false

  doctest MyDb.DbServer

  test "start/0 and stop/0" do
    assert Server.start() == :ok
    :timer.sleep(20)
    assert Process.whereis(Server) != nil

    assert Server.stop() == :ok
    :timer.sleep(20)
    assert Process.whereis(Server) == nil
  end

  test "write/2" do
    Server.start()
    assert Server.read(:foo) == { :error, :instance }
    assert Server.write(:foo, 5)
    assert Server.read(:foo) == { :ok, 5 }
    Server.stop()
  end

  test "delete/1" do
    Server.start()
    Server.write(:foo, 5)
    Server.write(:bar, 6)

    assert Server.delete(:foo) == :ok
    assert Server.read(:foo) == { :error, :instance }
    assert Server.read(:bar) == { :ok, 6 }
    Server.stop()
  end

  test "read/1" do
    Server.start()
    Server.write(:foo, 5)
    Server.write(:bar, 6)

    assert Server.read(:foo) == { :ok, 5 }
    assert Server.read(:baz) == { :error, :instance }

    Server.stop()
  end

  test "match/1" do
    Server.start()
    Server.write(:foo, 5)
    Server.write(:bar, 6)
    Server.write(:bam, 5)

    assert Server.match(5) |> Enum.sort == [:bam, :foo]
    assert Server.match(6) == [:bar]
    Server.stop()
  end
end
