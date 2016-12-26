defmodule Instruction do
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


  def execute({:inc, {:register, r}}, state) do
    Map.merge(state, %{:ip => state[:ip] + 1, r => state[r] + 1})
  end

  def execute({:dec, {:register, r}}, state) do
    Map.merge(state, %{:ip => state[:ip] + 1, r => state[r] - 1})
  end

  def execute({:cpy, {{:register, s}, {:register, d}}}, state) do
    Map.merge(state, %{:ip => state[:ip] + 1, d => state[s]})
  end

  def execute({:cpy, {{:value, v}, {:register, d}}}, state) do
    Map.merge(state, %{:ip => state[:ip] + 1, d => v})
  end

  def execute({:jnz, {comp, dest}}, state) do
    value  = Operand.value(comp, state)
    offset = Operand.value(dest, state)
    ip     = state[:ip] + if value != 0, do: offset, else: 1

    Map.merge(state, %{ip: ip})
  end


  defp parse_arguments(str) do
    String.split(str, ~r/\s+/)
    |> Enum.map(&Operand.parse(&1))
    |> List.to_tuple
  end
end

