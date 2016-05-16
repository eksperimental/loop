defmodule Loop.Sequential do
  @type fun :: (() -> term) | (term -> term) | (term, term -> term)

  @moduledoc """
  """

  @doc ~S"""
  Iterates over `term`, while `condition` is truthy, applying `fun`. It returns the accumulated terms.

    - `term` is any element that will be iterated over.
    - `condition` is the function that determines whether we should keep on iterating or not.
    - `transform` is applied to `term` at the end of every loop, before the next iteration,
       and will pass the transformed term to the next iteration. 
    - `fun` is run every time a `condition` is evaluated to truthy. 

  All the arguments that are functions can take 0, 1 or 2 arguments, being the first arg. `term`,
  and the second one is the accumulator.

  ## Examples

      iex> Loop.Sequential.loop(1, &(&1 <= 5))
      [1, 2, 3, 4, 5]

      # from 2.0 to -2.0, decreasing it by 0.5
      iex> Loop.Sequential.loop(2.0, &(&1 >= -2.0), &(&1 - 0.5))
      [2.0, 1.5, 1.0, 0.5, 0.0, -0.5, -1.0, -1.5, -2.0]

      # use of arity-2 condition
      # add to the list, while the sum of the previous items is <= 55
      Loop.Sequential.loop(1, fn _, acc -> Enum.sum(acc) <= 55 end)
      |> IO.inspect
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]

      iex> Loop.Sequential.loop(12345, &(String.length("#{&1}") <= 10), &(&1 * 7), &(:"#{&1}"))
      [:"12345", :"86415", :"604905", :"4234335", :"29640345", :"207482415", :"1452376905"]

  """
  @spec loop(term, __MODULE__.fun, __MODULE__.fun, __MODULE__.fun) :: list
  def loop(term, condition, transform \\ &(&1 + 1), fun \\ &(&1))
      when (is_function(condition, 0) or is_function(condition, 1) or is_function(condition, 2))
      and (is_function(transform, 0) or is_function(transform, 1) or is_function(transform, 2))
      and (is_function(fun, 0) or is_function(fun, 1) or is_function(fun, 2)) do
    do_loop(term, condition, transform, fun, [])
  end

  defp do_loop(current, condition, transform, fun, acc) do
    loop? = 
      cond do
        is_function(condition, 0) ->
          condition.()
        is_function(condition, 1) ->
          condition.(current)
        is_function(condition, 2) ->
          condition.(current, acc)
      end

    if loop? do
      result_transform =
        cond do
          is_function(transform, 0) ->
            transform.()
          is_function(transform, 1) ->
            transform.(current)
          is_function(transform, 2) ->
            transform.(current, acc)
        end

      result_fun =
        cond do
          is_function(fun, 0) ->
            fun.()
          is_function(fun, 1) ->
            fun.(current)
          is_function(fun, 2) ->
            fun.(current, acc)
        end

      do_loop(result_transform, condition, transform, fun, [result_fun | acc])
    else
      Enum.reverse(acc)
    end
  end
end
