defmodule InstructionTest do
  use ExUnit.Case

  test "parse" do
    tests = [
      {"add 3 a",  {:add, {{:value, 3}, {:register, :a}}}},
      {"mul b a",  {:mul, {{:register, :b}, {:register, :a}}}},
      {"nop",      {:nop}},
      {"jnz d -2", {:jnz, {{:register, :d}, {:value, -2}}}},
      {"inc c",    {:inc, {:register, :c}}},
      {"dec d",    {:dec, {:register, :d}}},
      {"tgl -3",   {:tgl, {:value, -3}}},
      {"cpy 9 a",  {:cpy, {{:value, 9}, {:register, :a}}}},
      {"out 4",    {:out, {:value, 4}}}
    ]

    Enum.each(tests, fn {s, p} -> assert Instruction.parse(s) == p end)
  end

  test "execute" do
    state = %{ip: 0, a: 0, b: 2, c: 4}
    prgm  = nil

    exec = fn(i, reg) ->
      {state, _} = i
      |> Instruction.parse
      |> Instruction.execute(state, prgm)
      state[reg]
    end

    assert exec.("inc a", :a) == 1
    assert exec.("dec c", :c) == 3
    assert exec.("add b c", :c) == 6
    assert exec.("mul b c", :c) == 8
  end
end
