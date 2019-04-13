defmodule Recurse do
  def sum(numbers, total \\ 0)

  def sum([head | tail], total) do
    IO.puts("Head: #{head} Tail: #{inspect(tail)}, Total: #{total}")
    total = total + head
    sum(tail, total)
  end

  def sum([], total), do: total

  def triple([head | tail]) do
    IO.puts("Head: #{head} Tail: #{inspect(tail)}")
    [head * 3 | triple(tail)]
  end

  def triple([]), do: []

  def main() do
    Recurse.sum([1, 2, 3, 4, 5])
  end
end
