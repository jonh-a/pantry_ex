defmodule PantryExTest do
  use ExUnit.Case
  doctest PantryEx

  test "invalid pantry returns error" do
    {status, reason} = PantryEx.get_pantry("invalid")
    assert status == :error
    assert reason == "Could not get pantry: pantry with id: invalid not found"
  end
end
