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
    adds = Enum.chunk(prgm, 3, 1)
    |> Enum.with_index
    |> Enum.reduce([], &find_optimization(&1, &2))
    |> Enum.reverse
    muls = Enum.chunk(prgm, 6, 1)
    |> Enum.with_index
    |> Enum.reduce([], &find_optimization(&1, &2))
    |> Enum.reverse

    muls ++ adds
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
      #              nop
      # cpy b c      nop
      # nop          cpy b a
      # add c a   => mul d a
      # cpy 0 c      cpy 0 c
      # dec d        cpy 0 d
      # jnz d -5
      [{:cpy, {{:register, b}, {:register, c}}},
       {:nop},
       {:add, {{:register, c}, {:register, a}}},
       {:cpy, {{:value, 0}, {:register, c}}},
       {:dec, {:register, d}},
       {:jnz, {{:register, d}, {:value, -5}}}] ->
        Logger.debug("found MUL optimization #{a} = #{b} * #{d} at #{index}")
        [{index,
          [
            {:nop},
            {:nop},
            {:cpy, {{:register, b}, {:register, a}}},
            {:mul, {{:register, d}, {:register, a}}},
            {:cpy, {{:value, 0}, {:register, c}}},
            {:cpy, {{:value, 0}, {:register, d}}}
          ]}
         | found ]
      _ -> found
    end
  end
end
