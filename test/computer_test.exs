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

  test "day23 part2" do
    prgm = Program.load("day23.input.txt")
    a = Computer.new(prgm, %{a: 12, b: 0, c: 0, d: 0})
    |> Computer.run
    |> Computer.register(:a)

    assert a == 479009322
  end


  test "day25 part1" do
    prgm = Program.load("day25.input.txt")
    a = Enum.find(0..100000, fn(i) ->
      c = Computer.new(prgm, %{a: i, b: 0, c: 0, d: 0})
      |> Computer.run_until(fn(c) -> length(Computer.signal(c)) == 10 end)

      if Computer.signal(c) == [0,1,0,1,0,1,0,1,0,1], do: i, else: false
    end)

    assert a == 198
  end
end
