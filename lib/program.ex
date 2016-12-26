defmodule Program do
  require Logger

  def load(filename) do
    {:ok, text} = File.read(filename)
    parse(text)
  end

  def parse(text) do
    String.split(text, "\n", trim: true)
    |> Enum.map(&Instruction.parse(&1))
  end

  def optimize(prgm) do
    orig = prgm
    prgm = find_optimizations(prgm) |> apply_optimizations(prgm)
    # continue optimizing until no more optimziations found
    if prgm == orig, do: prgm, else: optimize(prgm)
  end

  defp apply_optimizations([], prgm) do
    prgm
  end

  defp apply_optimizations([opt | rest], prgm) do
    prgm = apply_optimization(opt, prgm)
    apply_optimizations(rest, prgm)
  end

  defp apply_optimization({index, seq}, prgm) do
    seq_len = length(seq)
    {head, tail} = Enum.split(prgm, index)
    tail = Enum.drop(tail, seq_len)
    head ++ seq ++ tail
  end

  defp find_optimizations(prgm) do
    Enum.chunk(prgm, 3, 1)
    |> Enum.with_index
    |> Enum.reduce([], &find_optimization(&1, &2))
    |> Enum.reverse
  end

  defp find_optimization({instrs, index}, found) do
    case instrs do
      # inc a        nop
      # dec b     => add b a
      # jnz b -2     cpy 0 b
      [{:inc, {:register, a}}, {:dec, {:register, b}}, {:jnz, {{:register, b}, {:value, -2}}}] ->
        Logger.debug("found add optimization #{a} += #{b} at #{index}")
        [{index, [{:nop}, {:add, {{:register, b}, {:register, a}}}, {:cpy, {{:value, 0}, {:register, b}}}]} | found ]
      # dec b        nop
      # inc a     => add b a
      # jnz b -2     cpy 0 b
      [{:dec, {:register, b}}, {:inc, {:register, a}}, {:jnz, {{:register, b}, {:value, -2}}}] ->
        Logger.debug("found add optimization #{a} += #{b} at #{index}")
        [{index, [{:nop}, {:add, {{:register, b}, {:register, a}}}, {:cpy, {{:value, 0}, {:register, b}}}]} | found ]
      # cpy 0 a
      # cpy b c
      # nop
      # nop
      # add c a   => a = b * d
      # dec d
      # jnz d -5
        # [{:cpy, {{:value, 0}, {:register, a}}},
        #  {:cpy, {{:register, b}, {:register, c}}},
        #  {:nop},
        #  {:nop},
        #  {:add, {{:register, c}, {:register, a}}},
        #  {:dec, {:register, d}},
        #  {:jnz {{:register, d}, {:value, -5}}}] ->
        # [{index,
        #   [
        #     {:nop},
        #     {:nop},
        #     {:nop},
        #     {:nop},
        #     {:nop},
        #     {:nop},
        #     {:mul {{:register, b}, {:register, d}, {:register, a}}}]
        #  | found ]
      _ ->
        found
    end
  end
end
