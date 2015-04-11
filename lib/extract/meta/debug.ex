defmodule Extract.Meta.Debug do


  @total_size  79
  @prefix_size 10


  def ast(ast, kv \\ []) do
    info = Keyword.get(kv, :info, "Macro")
    headline "=", info, prefix_size: div(@prefix_size, 2)
    headline "-", "Code"
    IO.puts Macro.to_string(ast)
    case Keyword.get(kv, :ast, false) do
      false -> :ok
      true ->
        headline "-", "AST"
        :io.format "~p~n", [ast]
    end
    headline "-"
    newline
    ast
  end


  def headline(char, header \\ nil, kv \\ []) do
    prefix_size = Keyword.get(kv, :prefix_size, @prefix_size)
    total_size = Keyword.get(kv, :total_size, @total_size)
    info = case header do
      nil -> ""
      value -> " #{value} "
    end
    prefix = String.duplicate(char, prefix_size)
    postfix_size = max(0, total_size - prefix_size - String.length(info))
    postfix = String.duplicate(char, postfix_size)
    IO.puts "#{prefix}#{info}#{postfix}"
  end


  def newline do
    IO.puts ""
  end

end