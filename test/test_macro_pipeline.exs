defmodule TestSubMacro do

  def prepare(value) do
    IO.puts ">>>>> prepare"
    {value, []}
  end

  def terminate({value, context}) do
    IO.puts ">>>>> terminate: #{inspect context}"
    value
  end

  def mul({value, context}, number) do
    local_context = [:mul | context]
    IO.puts ">>>>> mul: #{inspect local_context}"
    {quote do
      unquote(value) * unquote(number)
     end,
     context}
  end

  def depend({value, context}, number) do
    local_context = [:depend | context]
    IO.puts ">>>>> depend: #{inspect context}"
    {pos_ast, _} = add({value, local_context}, number)
    {neg_ast, _} = sub({value, local_context}, number)
    {quote do
      case unquote(value) do
        value when value > 0 -> unquote(pos_ast)
        value when value < 0 -> unquote(neg_ast)
        value -> value
      end
     end,
     context}
  end


  def add({value, context}, number) do
    local_context = [:add | context]
    IO.puts ">>>>> add: #{inspect local_context}"
    {quote do
      unquote(value) + unquote(number)
     end,
     context}
  end

  def sub({value, context}, number) do
    local_context = [:sub | context]
    IO.puts ">>>>> sub: #{inspect local_context}"
    {quote do
      unquote(value) - unquote(number)
     end,
     context}
  end

end


defmodule TestMacro do

  import TestSubMacro

  defmacro test(value) do
    ast = value
    |> prepare
    |> mul(10)
    |> depend(5)
    |> add(1)
    |> terminate

    IO.puts "?????\n#{Macro.to_string(ast)}"

    ast
  end

end


defmodule TestMacroPipeline do

  require TestMacro

  def test(value) do
      TestMacro.test(value)
  end

end

