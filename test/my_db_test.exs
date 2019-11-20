defmodule MyDbTest do
  use ExUnit.Case
  doctest MyDb

  test "usage" do
    assert MyDb.start == :ok
    assert MyDb.write(:foo, 5) == :ok
    assert MyDb.write(:bar, 6) == :ok
    assert MyDb.write(:baz, 5) == :ok

    assert MyDb.read(:foo) == { :ok, 5 }
    assert MyDb.read(:blam) == { :error, :instance }

    assert MyDb.match(5) == { :ok, [:baz, :foo] }
    assert MyDb.match(6) == { :ok, [:bar] }
    assert MyDb.match(7) == { :ok, [] }

    assert MyDb.delete(:foo)
    assert MyDb.read(:foo) == { :error, :instance }

    assert MyDb.stop == :ok
  end
end
