defmodule Extract.Meta.Debug do


  @total_size  79
  @prefix_size 10


  def ast(ast, kv \\ []) do
    info = macro_info(Keyword.get(kv, :env), Keyword.get(kv, :caller))
    headline "=", info, prefix_size: div(@prefix_size, 2)
    headline "-", "Code"
    IO.puts Macro.to_string(ast)
    headline "-", "AST"
    :io.format "~p~n", [ast]
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


  defp macro_info(nil, nil), do: "Unknown Macro"

  defp macro_info(env, nil), do: identifier(env)

  defp macro_info(nil, caller) do
    "Unknown Macro used in #{identifier caller}"
  end

  defp macro_info(env, caller) do
    "#{identifier env} used in #{identifier caller}"
  end


  defp identifier(env) do
    mod = hd(env.context_modules)
    {fun, arity} = env.function
    line = env.line
    "#{mod}.#{fun}/#{arity}:#{line}"
  end

end