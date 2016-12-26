defmodule Computer do
  require Logger

  def new(src, state) do
    optimized = Program.optimize(src)
    %{program: optimized, src: src, state: Map.merge(state, %{ip: 0})}
  end

  def step(computer = %{program: prgm, src: src, state: state}) do
    instr = current_instruction(computer)
    {state, new_src} = Instruction.execute(instr, state, src)
    # if the instruction modified the source (tgl),
    # rengerated the new optimized code.
    {prgm, src} = if src != new_src do
      Logger.info("#{inspect(instr)} modified source, re-optimizing...")
      {new_src, Program.optimize(new_src)}
    else
      {prgm, src}
    end

    %{program: prgm, src: src, state: state}
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
