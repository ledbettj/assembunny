defmodule Instruction do
  use Instruction.Toggleable

  def parse("inc " <> register) do
    {:inc, {:register, String.to_atom(register)}}
  end

  def parse("dec " <> register) do
    {:dec, {:register, String.to_atom(register)}}
  end

  def parse("jnz " <> rest) do
    {:jnz, parse_arguments(rest)}
  end

  def parse("cpy " <> rest) do
    {:cpy, parse_arguments(rest)}
  end

  def parse("tgl " <> rest) do
    {:tgl, Operand.parse(rest)}
  end


  def execute({:inc, {:register, r}}, state, prgm) do
    {Map.merge(state, %{:ip => state[:ip] + 1, r => state[r] + 1}), prgm}
  end

  def execute({:dec, {:register, r}}, state, prgm) do
    {Map.merge(state, %{:ip => state[:ip] + 1, r => state[r] - 1}), prgm}
  end

  def execute({:cpy, {{:register, s}, {:register, d}}}, state, prgm) do
    {Map.merge(state, %{:ip => state[:ip] + 1, d => state[s]}), prgm}
  end

  def execute({:cpy, {{:value, v}, {:register, d}}}, state, prgm) do
    {Map.merge(state, %{:ip => state[:ip] + 1, d => v}), prgm}
  end

  def execute({:jnz, {comp, dest}}, state, prgm) do
    value  = Operand.value(comp, state)
    offset = Operand.value(dest, state)
    ip     = state[:ip] + if value != 0, do: offset, else: 1

    {Map.merge(state, %{ip: ip}), prgm}
  end

  def execute({:tgl, target}, state, prgm) do
    at = state[:ip] + Operand.value(target, state)
    prgm = if at >= 0 && at < length(prgm) do
      {head, [instr | rest]} = Enum.split(prgm, at)
      head ++ [Instruction.toggle(instr)] ++ rest
    else
      prgm
    end
    {Map.merge(state, %{ip: state[:ip] + 1}), prgm}
  end

  # Optimizer generated instructions
  def execute({:add, {{:register, src}, {:register, dest}}}, state, prgm) do
    {Map.merge(state, %{:ip => state[:ip] + 1, dest => state[dest] + state[src]}), prgm}
  end

  def execute({:nop}, state, prgm) do
    {Map.merge(state, %{ip: state[:ip] + 1}), prgm}
  end

  defp parse_arguments(str) do
    String.split(str, ~r/\s+/)
    |> Enum.map(&Operand.parse(&1))
    |> List.to_tuple
  end
end

