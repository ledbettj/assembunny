# Asmbunny

This is an elixir implementation of the Assembunny assembly code from
2016 Advent of Code.


## Usage

```elixir
p = Program.load("code.asb")
c = Computer.new(p, %{a: 0, b: 0, c: 0, d: 0}) |> Computer.run
IO.puts("a is #{Computer.register(c, :a)}")
```


