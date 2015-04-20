defmodule Extract.Meta.Debug do


  @total_size  79
  @prefix_size 10


  def ast(ast, kv \\ []) do
    info = Keyword.get(kv, :info)
    env = Keyword.get(kv, :env)
    caller = Keyword.get(kv, :caller)
    title = debug_info(info, env, caller)
    headline "=", title, prefix_size: div(@prefix_size, 2)
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


  defp debug_info(nil, nil, nil), do: "Unknown Macro"

  defp debug_info(nil, env, nil), do: call_from_env(env)

  defp debug_info(nil, nil, caller) do
    "Unknown Macro used in #{call_from_env caller}"
  end

  defp debug_info(nil, env, caller) do
    "#{call_from_env env} used in #{call_from_env caller}"
  end

  defp debug_info(info, env, caller) do
    "#{info}: " <> debug_info(nil, env, caller)
  end


  defp call_from_env(env) do
    case {env.context_modules, env.function, env.line} do
      {[mod | _], {fun, arity}, line} when is_integer(line) and line > 0 ->
        "#{strip_module mod}.#{fun}/#{arity}:#{line}"
      {_, {fun, arity}, line} when is_integer(line) and line > 0 ->
        "#{fun}/#{arity}:#{line}"
      {[mod | _], {fun, arity}, _} ->
        "#{strip_module mod}.#{fun}/#{arity}"
      {_, {fun, arity}, _} ->
        "#{fun}/#{arity}"
      {[mod | _], _, _} ->
        "Unknown #{mod} function"
      {_, _, _} ->
        "Unknown function"
    end
  end


  defp strip_module(mod) when is_atom(mod) do
    strip_module(Atom.to_string(mod))
  end

  defp strip_module("Elixir." <> mod), do: mod

  defp strip_module(mod), do: mod

end