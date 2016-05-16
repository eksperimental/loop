defmodule Loop.Concurrent do
  @type fun :: (() -> term) | (term -> term)

  @moduledoc """
  """

  @doc ~S"""
  Iterates over `term`, while `condition` is truthy, applying `fun`. It returns the accumulated terms.

    - `term` is any element that will be iterated over.
    - `condition` can take no arguments, or 1 argument(`term).
    - `transform` is applied to `term` at the end of every loop, before the next iteration.
    - `fun` is run every time a `condition` is evaluated to truthy. 

  All the arguments that are functions can take 0, 1 or 2 arguments, being the first arg. `term`,
  and the second one is the accumulator.

  `condition` and `transform` are evaluated sequentially.
  `fun` is run concurrently.

  Note because `fun` is not sequential, the order of execution is not guaranteed, but the results
  are guaranted to be returned in the order they were passed on.

  Note also that unlike `Loop.Sequential.loop/4`, the functions here will not take 2 arguments.
  This is because an accumulator is not kept during the concurrent calls. You may want to apply
  `Enum.filter/2` to the result, or use `Loop.Sequential.loop/4`.

  ## Examples

      iex> Loop.Concurrent.loop(1, &(&1 <= 5))
      [1, 2, 3, 4, 5]

    
  Lines will be printed a different order (since they were executed at different times),
  but the result is returned in the given order.
  Even if the wait is constant, the results order won't necessarily be kept.

      iex> Loop.Concurrent.loop(1, &(&1 <= 10), &(&1 + 1),
      ...>   fn(x) ->
      ...>    square = x * x
      ...>
      ...>    # a resource intensive process that will take time
      ...>    :timer.sleep(Enum.random([0, 500, 1000]))
      ...>
      ...>    IO.write("#{square} ")
      ...>    square
      ...> end)
      #=> 16 100 4 9 25 49 1 36 64 81
      [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]

      {mtime, _} = :timer.tc(fn ->
        Loop.Concurrent.loop(1, &(&1 <= 100_000), &(&1 + 2), fn(x) ->
          # a resource intensive process that will take time
          :timer.sleep(1000)
          x * -1
        end)
      end)
      IO.puts "time elapsed: #{Float.ceil(mtime / 1000000, 2)} seconds"
      #=> "time elapsed: 11.22 seconds"

  Meaning we spent 10 seconds waiting, and 1.22 looping and processing 100,000 times.

  """
  @spec loop(term, __MODULE__.fun, __MODULE__.fun, __MODULE__.fun) :: list
  def loop(term, condition, transform \\ &(&1 + 1), fun \\ &(&1))
      when (is_function(condition, 0) or is_function(condition, 1) or is_function(condition, 2))
      and (is_function(transform, 0) or is_function(transform, 1) or is_function(transform, 2))
      and (is_function(fun, 0) or is_function(fun, 1) or is_function(fun, 2)) do
    {:ok, pids} = dispatch_loop(term, condition, transform, fun, self)
    {:ok, results} = receiver(pids)
    results
  end

  defp dispatch_loop(current, condition, transform, fun, caller_pid, pids \\ []) do
    loop? = 
      cond do
        is_function(condition, 0) ->
          condition.()
        is_function(condition, 1) ->
          condition.(current)
      end

    if loop? do
      result_transform =
        cond do
          is_function(transform, 0) ->
            transform.()
          is_function(transform, 1) ->
            transform.(current)
        end

      pid = spawn_link(fn ->
        # this message will be consumed by receiver/2
        send(caller_pid, {self, concurrent_fun(fun, current)})
      end)

      dispatch_loop(result_transform, condition, transform, fun, caller_pid, [pid | pids])
    else
      {:ok, Enum.reverse(pids)}
    end
  end

  @spec concurrent_fun(__MODULE__.fun, term) :: term
  defp concurrent_fun(fun, _current) when is_function(fun, 0),
    do: fun.()
  defp concurrent_fun(fun, current) when is_function(fun, 1),
    do: fun.(current)

  @spec receiver([pid], list) :: {:ok, list}
  defp receiver(pids, acc \\ [])
  defp receiver([], acc),
    do: {:ok, Enum.reverse(acc)}

  defp receiver([pid | pids_rest], acc) do
    receive do
      {^pid, data} ->
        # we pin pid (^) so the processes are returned in order
        receiver(pids_rest, [data | acc])
    end
  end
end
