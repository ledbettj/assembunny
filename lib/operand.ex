defmodule Operand do
  def parse(str) do
    case Integer.parse(str) do
      :error    -> {:register, String.to_atom(str)}
      {val, ""} -> {:value, val}
    end
  end

  def value({:value, v}, _), do: v
  def value({:register, r}, state), do: state[r]
end
