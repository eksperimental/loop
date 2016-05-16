defmodule LoopTest do
  use ExUnit.Case, async: true

  doctest Loop
  doctest Loop.Basic
  doctest Loop.Sequential
  doctest Loop.Concurrent

  test "basic examples loop/4 w/2 args" do
    assert [1, 2, 3, 4, 5] == Loop.Basic.loop(1, &(&1 <= 5))
    assert [1, 2, 3, 4, 5] == Loop.Sequential.loop(1, &(&1 <= 5))
    assert [1, 2, 3, 4, 5] == Loop.Concurrent.loop(1, &(&1 <= 5))
  end

  test "basic examples loop/4 w/3 args" do
    assert [1, 3, 9, 27, 81] == Loop.Basic.loop(1, &(&1 <= 100), &(&1 * 3))
    assert [1, 3, 9, 27, 81] == Loop.Basic.loop(1, &(&1 <= 100), &(&1 * 3))
    assert [1, 3, 9, 27, 81] == Loop.Basic.loop(1, &(&1 <= 100), &(&1 * 3))

    assert [5, 4, 3, 2, 1, 0, -1, -2, -3, -4, -5]
      == Loop.Basic.loop(5, &(&1 >= -5), &(&1 - 1))

    assert [5, 4, 3, 2, 1, 0, -1, -2, -3, -4, -5]
      == Loop.Sequential.loop(5, &(&1 >= -5), &(&1 - 1))

    assert [5, 4, 3, 2, 1, 0, -1, -2, -3, -4, -5]
      == Loop.Concurrent.loop(5, &(&1 >= -5), &(&1 - 1))
  end

  test "basic examples loop/4 w/4 args" do
    assert ["1", "3", "9", "27", "81"] == Loop.Basic.loop(1, &(&1 <= 100), &(&1 * 3), &(Integer.to_string(&1)))
    assert ["1", "3", "9", "27", "81"] == Loop.Basic.loop(1, &(&1 <= 100), &(&1 * 3), &(Integer.to_string(&1)))
    assert ["1", "3", "9", "27", "81"] == Loop.Basic.loop(1, &(&1 <= 100), &(&1 * 3), &(Integer.to_string(&1)))
  end
end
