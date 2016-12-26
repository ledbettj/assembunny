defmodule Program do
  def load(filename) do
    {:ok, text} = File.read(filename)
    parse(text)
  end

  def parse(text) do
    String.split(text, "\n", trim: true)
    |> Enum.map(&Instruction.parse(&1))
  end

  def optimize(program) do
    program
  end
end
