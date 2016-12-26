defmodule Instruction.Toggleable do
  defmacro __using__(_) do
    quote location: :keep do
      def toggle({:inc, args}) do
        {:dec, args}
      end

      def toggle({:dec, args}) do
        {:inc, args}
      end

      def toggle({:tgl, args}) do
        {:inc, args}
      end

      def toggle({:jnz, args}) do
        {:cpy, args}
      end

      def toggle({:cpy, args}) do
        {:jnz, args}
      end
    end
  end
end
