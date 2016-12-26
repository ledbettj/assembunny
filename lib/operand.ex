defmodule Operand do
  # parse "a" into {:register, :a}
  # parse "12" into {:value, 12}
  def parse(str) do
    case Integer.parse(str) do
      :error    -> {:register, String.to_atom(str)}
      {val, ""} -> {:value, val}
    end
  end

  # get the value of an operand.
  # if it's an immediate value, just return it, otherwise lookup register value.
  def value({:value, v}, _), do: v
  def value({:register, r}, state), do: state[r]
end
