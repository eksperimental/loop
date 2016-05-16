# Loop

Loops implemented in Elixir

Stem from [a discussion in the ElixirForum](http://elixirforum.com/t/how-to-do-a-for-loop-in-elixir-using-only-recursion/595/1) about how to create a loop in a functional language like Elixir, only using recursion. This library it is more of an experiment than a library in itself.

`Loop.Basic.loop/4` answers the original question .

`Loop.Sequential.loop/4` is a bit more elaborate, allowing to use functions with more arities,
allow users to use no arguments, or two (term, and accumulator), in addition to the only one
argument allowed in `Loop.Basic.loop/4`.

`Loop.Concurrent.loop/4` takes it even a step further, making use of Elixir concurrency model.
This function dispatches `fun` concurrently.

The basic usage of `Loop.Sequential.loop/4` and `Loop.Concurrent.loop/4` is

`loop(term, condition, transform, fun)`

- `term` is any value that will be first passed to the loop.
- `condition` will be evaluated at every new iteration and determined if should continue or stop.
- `transform` will transform `term` at every iteration, and pass the transformed value to the next
  recursive loop call.
- `fun` is what will be executed in every iteration. Results of each iteration are returned in a list.
  If you care about the the order that this function is going to be executed,
  use `Loop.Sequential`. If all you care is about speed and the
  final result, then use `Loop.Concurrent`.

  In `Loop.Sequential.loop/4`, all three functions (`condition`, `transform` and `fun`) accept 0, 1 and 2 arguments; being first argument `term` and second the accumulator stored from previous iterations (starting with an empty list (`[]`)).

  In `Loop.Concurrent.loop/4`, all three functions (`condition`, `transform` and `fun`) accept 1 or no arguments; being `term` the argument used with arity 1.

## Examples

    iex> Loop.Sequential.loop(1, &(&1 <= 5))
    [1, 2, 3, 4, 5]

    # from 2.0 to -2.0, decreasing it by 0.5
    iex> Loop.Sequential.loop(2.0, &(&1 >= -2.0), &(&1 - 0.5))
    [2.0, 1.5, 1.0, 0.5, 0.0, -0.5, -1.0, -1.5, -2.0]

    iex> Loop.Sequential.loop(12345, &(String.length("#{&1}") <= 10), &(&1 * 7), &(:"#{&1}"))
    [:"12345", :"86415", :"604905", :"4234335", :"29640345", :"207482415", :"1452376905"]

    iex> Loop.Concurrent.loop(1, &(&1 <= 5))
    [1, 2, 3, 4, 5]

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


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add loop to your list of dependencies in `mix.exs`:

        def deps do
          [{:loop, "~> 0.0.1"}]
        end

  2. Ensure loop is started before your application:

        def application do
          [applications: [:loop]]
        end

