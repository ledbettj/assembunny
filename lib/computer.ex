defmodule Computer do
  require Logger

  # Create a new Computer to run the given program source.
  def new(src, state) do
    optimized = Program.optimize(src)
    %{program: optimized, src: src, state: Map.merge(state, %{ip: 0, seq: []})}
  end

  # Execute a single instruction from the program
  def step(computer = %{program: prgm, src: src, state: state}) do
    instr = current_instruction(computer)
    # Logger.debug("#{inspect(state)} - #{inspect(instr)}")
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

  # Return the value of a given register
  def register(%{state: state}, which) do
    state[which]
  end

  def signal(%{state: state}) do
    Enum.reverse(state[:seq])
  end

  # Execute the program until it halts
  def run(computer) do
    if halted?(computer), do: computer, else: step(computer) |> run
  end

  # Execute the program until it halts or func returns true
  def run_until(computer, func) do
    if halted?(computer) || func.(computer) do
      computer
    else
      step(computer) |> run_until(func)
    end
  end

  # Check if the program is halted
  def halted?(%{program: prgm, state: state}) do
    state[:ip] >= length(prgm)
  end

  # Return the next instruction to execute, pointed to by the Instruction Pointer
  defp current_instruction(%{program: prgm, state: state}) do
    Enum.at(prgm, state[:ip])
  end
end
