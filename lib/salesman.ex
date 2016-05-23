defmodule Salesman do
  require Integer
  alias Salesman.TestData

  def death_of(matrix, start_point) do
    x_base =
      sort_by(matrix, "x")
      |> ideal_by_axis
      |> set_start(start_point)

    y_base =
      sort_by(matrix, "y")
      |> ideal_by_axis
      |> set_start(start_point)

    finish_him(x_base, y_base, start_point)
  end

  def tour(matrix, start_point) do
    x_base =
      sort_by(matrix, "x")
      |> set_start(start_point)
    y_base =
    sort_by(matrix, "y")
    |> set_start(start_point)

    finish_him(x_base, y_base, start_point)
  end

  def test_tiny do
    solution = death_of(TestData.tiny, List.first(TestData.tiny))
    "Length of Route: #{distance_of(solution)}"
  end

  def test_small do
    solution = death_of(TestData.small, List.first(TestData.small))
    "Length of Route: #{distance_of(solution)}"
  end

  def test_big do
    solution = death_of(TestData.big, List.first(TestData.big))
    "Length of Route: #{distance_of(solution)}"
  end

  def test_tour_big do
    solution = tour(TestData.big, List.first(TestData.big))
    "Length of Route: #{distance_of(solution)}"
  end

  def sort_by(matrix, axis) do
    case axis do
      "x" ->
        Enum.sort(matrix, &(elem(&1, 0) < elem(&2, 0)))
      "y" ->
        Enum.sort(matrix, &(elem(&1, 1) < elem(&2, 1)))
      _ ->
        {:error, "Select either 'x' or 'y' for axis"}
    end
  end

  def ideal_by_axis(axis), do: _ideal_by_axis(axis, 1, [], [])
  defp _ideal_by_axis([], _, even, odd), do: odd ++ even
  defp _ideal_by_axis([head|tail], num, even, odd) when Integer.is_even(num) do
    _ideal_by_axis(tail, num + 1, [head] ++ even, odd)
  end
  defp _ideal_by_axis([head|tail], num, even, odd) when Integer.is_odd(num) do
    _ideal_by_axis(tail, num + 1, even, odd ++ [head])
  end

  def set_start(axis, start_point), do: _set_start(axis, start_point, [], [])
  defp _set_start([], _, back, front), do: front ++ back
  defp _set_start([head|tail], sp, back, front) when head != sp do
    _set_start(tail, sp, back ++ [head], front)
  end
  defp _set_start([head|tail], sp, back, _front) when head == sp do
    _set_start([], sp, back, [head] ++ tail)
  end

  def finish_him(x, y, start_point), do: _finish_him(x, y, start_point, [])
  def _finish_him([], [], _, solution), do: solution
  def _finish_him([head_x|tail_x], [head_y|tail_y], start_point, solution) do
    new_point =
      cond do
        head_x == head_y ->
          head_x
        true ->
          case find_closest(head_x, head_y, List.last(solution)) do
            {:x, key} ->
              tail_y = List.keyreplace(tail_y, key, 2, head_y)
              head_x
            {:y, key} ->
              tail_x = List.keyreplace(tail_x, key, 2, head_x)
              head_y
          end
      end
    _finish_him(tail_x, tail_y, start_point, solution ++ [new_point])
  end

  defp find_closest(x, y, last) do
    if abs(elem(x, 1) - elem(last, 1)) < abs(elem(y, 0) - elem(last, 0)) do
      {:x, elem(x, 2)}
    else
      {:y, elem(y, 2)}
    end
  end

  def distance_of(solution), do: _distance_of(solution, 0)
  defp _distance_of([], acc), do: acc
  defp _distance_of([head|tail], acc) do
    case tail do
      [] ->
        acc
      _ ->
        x = abs(elem(List.first(tail), 0) - elem(head, 0))
        y = abs(elem(List.first(tail), 1) - elem(head, 1))
        x_sqr = x * x
        y_sqr = y * y
        _distance_of(tail, acc + :math.sqrt(x_sqr + y_sqr))
    end
  end
end
