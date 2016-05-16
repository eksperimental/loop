defmodule Loop do
  @moduledoc ~S"""
  `Loop` is composed of submodules:
  - `Loop.Basic`: shows basic sequential for-loop-like functionality in Elixir.
  - `Loop.Sequential`: Sequential for-loop-like functionality in Elixir.
  - `Loop.Sequential`: Concurrent for-loop-like functionality in Elixir.

  ### Concurrent vs. Sequential

  `Loop.Sequential.loop/4`: lines are printed in the right order but the execution time is long

      {mtime, result} = :timer.tc(fn ->
        Loop.Sequential.loop(1, &(&1 <= 10), &(&1 + 1),
          fn(x) ->
           square = x * x
           # a resource intensive process that will take time
           :timer.sleep(2000)
           IO.write("#{square} ")
           square
          end
        )|> IO.inspect
      end)
      #=> 1 4 9 16 25 36 49 64 81 100
      IO.puts "time elapsed (sequential): #{Float.ceil(mtime / 1000000, 2)} seconds"
      #=> time elapsed (sequential): 20.02 seconds

  `Loop.Concurrent.loop/4`: lines are printed in the right order, but the result is returned in the
  right order

      {mtime, _} = :timer.tc(fn ->
        Loop.Concurrent.loop(1, &(&1 <= 10), &(&1 + 1),
          fn(x) ->
           square = x * x
           # a resource intensive process that will take time
           :timer.sleep(2000)
           IO.write("#{square} ")
           square
          end
        )|> IO.inspect
      end)
      IO.puts "time elapsed (concurrent): #{Float.ceil(mtime / 1000000, 2)} seconds"
      #=> 1 4 9 16 25 36 49 64 81 100
      #=> time elapsed (concurrent): 2.01 seconds

  Note that the printed results from the concurrent version are not in the right order.

  """
end
