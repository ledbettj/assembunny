defmodule Program do
  # read a file and generate a program from it.
  def load(filename) do
    {:ok, text} = File.read(filename)
    parse(text)
  end

  # read a text blob and generate a program from it.
  def parse(text) do
    String.split(text, "\n", trim: true)
    |> Enum.map(&Instruction.parse(&1))
  end

  # given an input program, make optimization passes on it until
  # we find nothing left to optimize
  def optimize(prgm) do
    Optimizer.optimize(prgm)
  end
end
