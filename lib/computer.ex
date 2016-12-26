defmodule Computer do
  def new(prgm, state) do
    %{program: prgm, state: Map.merge(state, %{ip: 0})}
  end

  def step(computer = %{program: prgm, state: state}) do
    {state, prgm} = current_instruction(computer) |> Instruction.execute(state, prgm)

    %{program: prgm, state: state}
  end

  def register(%{state: state}, which) do
    state[which]
  end

  def run(computer) do
    if halted?(computer), do: computer, else: step(computer) |> run
  end

  def halted?(%{program: prgm, state: state}) do
    state[:ip] >= length(prgm)
  end

  defp current_instruction(%{program: prgm, state: state}) do
    Enum.at(prgm, state[:ip])
  end
end
