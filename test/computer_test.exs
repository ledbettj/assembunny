defmodule ComputerTest do
  use ExUnit.Case

  test "day12 part 1" do
    prgm = Program.load("day12.input.txt")
    a = Computer.new(prgm, %{a: 0, b: 0, c: 0, d: 0})
    |> Computer.run
    |> Computer.register(:a)

    assert a == 318020
  end

  test "day12 part 2" do
    prgm = Program.load("day12.input.txt")
    a = Computer.new(prgm, %{a: 0, b: 0, c: 1, d: 0})
    |> Computer.run
    |> Computer.register(:a)

    assert a == 9227674
  end

  test "day23 part1" do
    prgm = Program.load("day23.input.txt")
    a = Computer.new(prgm, %{a: 7, b: 0, c: 0, d: 0})
    |> Computer.run
    |> Computer.register(:a)

    assert a == 12762
  end
end
