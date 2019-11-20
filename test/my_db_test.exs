defmodule MyDbTest do
  use ExUnit.Case
  doctest MyDb

  test "greets the world" do
    assert MyDb.hello() == :world
  end
end
