defmodule Optimizer do
  def optimize(program) do
    source    = program
    optimized = find_optimizations(source) |> apply_optimizations(source)

    # continue optimizing until no more optimziations found
    if source == optimized, do: optimized, else: optimize(optimized)
  end

  # base case, no optimizations to apply.
  defp apply_optimizations([], program) do
    program
  end

  # apply all optimizations
  defp apply_optimizations([opt | rest], program) do
    program = apply_optimization(opt, program)
    apply_optimizations(rest, program)
  end

  # replace the instructions at [index, len] with seq
  defp apply_optimization({index, seq}, program) do
    seq_len = length(seq)
    {head, tail} = Enum.split(program, index)
    tail = Enum.drop(tail, seq_len)
    head ++ seq ++ tail
  end

  defp find_optimizations(program) do
    adds = Enum.chunk(program, 3, 1)
    |> Enum.with_index
    |> Enum.reduce([], &find_optimization(&1, &2))
    |> Enum.reverse
    muls = Enum.chunk(program, 6, 1)
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
        [{index, [{:nop}, {:add, {{:register, b}, {:register, a}}}, {:cpy, {{:value, 0}, {:register, b}}}]} | found ]
      # dec b        nop
      # inc a     => add b a
      # jnz b -2     cpy 0 b
      [{:dec, {:register, b}}, {:inc, {:register, a}}, {:jnz, {{:register, b}, {:value, -2}}}] ->
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
