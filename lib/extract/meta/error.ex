defmodule Extract.Meta.Error do

  alias Extract.Meta.Context


  @error_alias {:__aliases__, [alias: false], [:Extract, :Meta, :Error]}


  defmacro comptime(ctx, {f, c, a})
   when is_atom(f) and (is_list(a) or a == nil) do
    alias_ast = {:__aliases__, [alias: false], [:Extract, :Meta, :Error]}
    fun_name = String.to_atom("comptime_" <> Atom.to_string(f))
    aliased_fun = {:., [], [alias_ast, fun_name]}
    props_ast = quote do: Context.properties(unquote(ctx))
    args = if a == nil, do: [props_ast], else: a ++ [props_ast]
    {aliased_fun, c, args}
  end


  defmacro runtime(ctx, {:&, _, [{:/, _, [{f, c, a}, n]}]})
   when is_atom(f) and is_atom(a) and is_integer(n) and n >= 0 do
    fun_name = String.to_atom("runtime_" <> Atom.to_string(f))
    quote do
      props = Context.properties(unquote(ctx))
      vars = for i <- :lists.seq(1, unquote(n)) do
        Macro.var(String.to_atom("param#{i}") , __MODULE__)
      end
      alias_ast = {:__aliases__, [alias: false], [:Extract, :Meta, :Error]}
      aliased_fun = {:., [], [alias_ast, unquote(fun_name)]}
      {{aliased_fun, unquote(c), vars ++ [props]}, vars}
    end
  end

  defmacro runtime(ctx, {f, c, a})
   when is_atom(f) and (is_list(a) or is_atom(a)) do
    args = if is_atom(a), do: [], else: a
    fun_name = String.to_atom("runtime_" <> Atom.to_string(f))
    quote do
      props = Context.properties(unquote(ctx))
      alias_ast = {:__aliases__, [alias: false], [:Extract, :Meta, :Error]}
      aliased_fun = {:., [], [alias_ast, unquote(fun_name)]}
      {aliased_fun, unquote(c), unquote(args) ++ [props]}
    end
  end


  def comptime_error(reason, message, _kv \\ []) do
    reason = {:compile_error, reason}
    message = "compilation error, #{message}"
    raise Extract.Error, reason: reason, message: message
  end


  def comptime_bad_format(format, _kv \\ []) do
    reason = {:bad_format, format}
    message = "invalid format #{inspect format}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_bad_format(format, _kv \\ []) do
    quote do
      raise Extract.Error,
        reason: {:bad_format, unquote(format)},
        message: "invalid format #{inspect unquote(format)}"
    end
  end


  def comptime_undefined_value(kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:undefined_value, tag}
    message = "undefined#{desc} value"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_undefined_value(kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:undefined_value, tag}
    message = "undefined#{desc} value"
    quote do
      raise Extract.Error, reason: unquote(reason), message: unquote(message)
    end
  end


  def comptime_missing_value(kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:missing_value, tag}
    message = "missing#{desc} value"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_missing_value(kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:missing_value, tag}
    message = "missing#{desc} value"
    quote do
      raise Extract.Error, reason: unquote(reason), message: unquote(message)
    end
  end


  defp type_info(kv) do
    case Keyword.fetch(kv, :type_info) do
      :error -> {:unknwon, ""}
      {:ok, []} -> {:unknown, ""}
      {:ok, [{tag, desc}]} -> {tag, " #{desc}"}
    end
  end

end
