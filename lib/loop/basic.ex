defmodule Loop.Basic do
  @doc ~S"""
  Basic loop version. Iterates over `term`, while `condition` is truthy, applying `fun`.
  It returns the accumulated terms.

    - `term` is any element that will be iterated over.
    - `condition` is the function that determines whether we should keep on iterating or not.
    - `transform` is applied to `term` at the end of every loop, before the next iteration,
       and will pass the transformed term to the next iteration. 
    - `fun` is run every time a `condition` is evaluated to truthy. 

  `condition`, `transform` and `fun` take the current term as the argument.

  This function is a basic version of `Loop.Sequential.loop/4` where function only take 1 argument.
  Only used for demonstration purposes.
  Please see `Loop.Sequential.loop/4` or `Loop.Concurrent.loop/4` for a full version.

  ## Examples

      iex> Loop.Basic.loop(1, &(&1 <= 5))
      [1, 2, 3, 4, 5]

      # from 2.0 to -2.0, decreasing it by 0.5
      iex> Loop.Basic.loop(2.0, &(&1 >= -2.0), &(&1 - 0.5))
      [2.0, 1.5, 1.0, 0.5, 0.0, -0.5, -1.0, -1.5, -2.0]

      iex> Loop.Basic.loop(12345, &(String.length("#{&1}") <= 10), &(&1 * 7), &(:"#{&1}"))
      [:"12345", :"86415", :"604905", :"4234335", :"29640345", :"207482415", :"1452376905"]

  """
  @spec loop(term, (term -> term), (term -> term), (term -> term)) :: list
  def loop(term, condition, transform \\ &(&1 + 1), fun \\ &(&1))
      when is_function(condition, 1) and is_function(transform, 1) and is_function(fun, 1) do
    do_loop(term, condition, transform, fun, [])
  end

  defp do_loop(current, condition, transform, fun, acc) do
    if condition.(current) do
      do_loop(transform.(current), condition, transform, fun, [fun.(current) | acc])
    else
      Enum.reverse(acc)
    end
  end  
end
