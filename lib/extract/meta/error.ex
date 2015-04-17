defmodule Extract.Meta.Error do

  alias Extract.Meta.Context


  @error_alias {:__aliases__, [alias: false], [:Extract, :Meta, :Error]}


  defmacro comptime(ctx, {f, c, a})
   when is_atom(f) and (is_list(a) or a == nil) do
    alias_ast = {:__aliases__, [alias: false], [:Extract, :Meta, :Error]}
    fun_name = String.to_atom("comptime_" <> Atom.to_string(f))
    aliased_fun = {:., [], [alias_ast, fun_name]}
    props_ast = quote do: Context.properties(unquote(ctx))
    args = if is_list(a), do: a ++ [props_ast], else: [props_ast]
    _ast = {aliased_fun, c, args}
    # Extract.Meta.Debug.ast(_ast, info: "Error.comptime")
  end


  defmacro runtime(ctx, {:/, _, [{f, c, a}, n]})
   when is_atom(f) and is_integer(n) and n >= 0 do
    fun_name = String.to_atom("runtime_" <> Atom.to_string(f))
    args = if is_list(a), do: a, else: []
    quote do
      props = Context.properties(unquote(ctx))
      vars = for i <- :lists.seq(1, unquote(n)) do
        Macro.var(String.to_atom("param#{i}") , __MODULE__)
      end
      alias_ast = {:__aliases__, [alias: false], [:Extract, :Meta, :Error]}
      aliased_fun = {:., [], [alias_ast, unquote(fun_name)]}
      {{aliased_fun, unquote(c), vars ++ unquote(args) ++ [props]}, vars}
    end
  end

  defmacro runtime(ctx, {f, c, a})
   when is_atom(f) and (is_list(a) or is_atom(a)) do
    fun_name = String.to_atom("runtime_" <> Atom.to_string(f))
    args = if is_list(a), do: a, else: []
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


  def comptime_bad_receipt(from, to, _kv \\ []) do
    reason = {:bad_receipt, {from, to}}
    message = "invalid receipt from #{inspect from} to %{inspect to}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_bad_receipt(from, to, _kv \\ []) do
    quote do
      raise Extract.Error,
        reason: {:bad_receipt, {unquote(from), unquote(to)}},
        message: "invalid receipt from #{inspect unquote(from)} "
                 <> "to %{inspect unquote(to)}"
    end
  end


  def comptime_undefined_value(kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:undefined_value, tag}
    message = "undefined #{desc}value"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_undefined_value(kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:undefined_value, tag}
    message = "undefined #{desc}value"
    quote do
      raise Extract.Error, reason: unquote(reason), message: unquote(message)
    end
  end


  def comptime_missing_value(kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:missing_value, tag}
    message = "missing #{desc}value"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_missing_value(kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:missing_value, tag}
    message = "missing #{desc}value"
    quote do
      raise Extract.Error, reason: unquote(reason), message: unquote(message)
    end
  end


  def comptime_value_not_allowed(value, kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:value_not_allowed, tag}
    message = "#{desc}value not allowed: #{value}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_value_not_allowed(value, kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:value_not_allowed, tag}
    message = "#{desc}value not allowed: "
    quote do
      raise Extract.Error,
        reason: unquote(reason),
        message: unquote(message) <> inspect(unquote(value))
    end
  end


  def comptime_bad_value(value, kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:bad_value, {tag, :bad_type}}
    message = "bad #{desc}value: #{inspect value}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_bad_value(value, kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:bad_value, {tag, :bad_type}}
    message = "bad #{desc}value: "
    quote do
      raise Extract.Error,
        reason: unquote(reason),
        message: unquote(message) <> inspect(unquote(value))
    end
  end


  def comptime_value_too_big(value, max, kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:bad_value, {tag, :too_big}}
    message = "#{desc}value bigger than #{max}: #{value}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_value_too_big(value, max, kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:bad_value, {tag, :too_big}}
    message = "#{desc}value bigger than #{max}: "
    quote do
      raise Extract.Error,
        reason: unquote(reason),
        message: unquote(message) <> inspect(unquote(value))
    end
  end


  def comptime_value_too_small(value, min, kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:bad_value, {tag, :too_small}}
    message = "#{desc}value smaller than #{min}: #{value}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_value_too_small(value, min, kv \\ []) do
    {tag, desc} = type_info(kv)
    reason = {:bad_value, {tag, :too_small}}
    message = "#{desc}value smaller than #{min}: "
    quote do
      raise Extract.Error,
        reason: unquote(reason),
        message: unquote(message) <> inspect(unquote(value))
    end
  end


  def comptime_distillation_error(value, kv \\ []) do
    {from_tag, to_tag, desc} = conv_info(kv)
    reason = {:distillation_error, {from_tag, to_tag}}
    message = "error converting value#{desc}: #{inspect value}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_distillation_error(value, kv \\ []) do
    {from_tag, to_tag, desc} = conv_info(kv)
    reason = {:distillation_error, {from_tag, to_tag}}
    message = "error converting value#{desc}: "
    quote do
      raise Extract.Error,
        reason: unquote(reason),
        message: unquote(message) <> inspect(unquote(value))
    end
  end


  defp type_info(kv) do
    case Keyword.fetch(kv, :type_info) do
      :error -> {:unknwon, ""}
      {:ok, []} -> {:unknown, ""}
      {:ok, [{tag, desc} | _]} -> {tag, "#{desc} "}
    end
  end


  defp conv_info(kv) do
    case Keyword.fetch(kv, :type_info) do
      :error -> {:unknwon, :unknwon, ""}
      {:ok, []} -> {:unknown, :unknwon, ""}
      {:ok, [{to_tag, to_desc}]} -> {:unknown, to_tag, " to #{to_desc}"}
      {:ok, [{to_tag, to_desc}, {from_tag, from_desc} | _]} ->
        {from_tag, to_tag, " from #{from_desc} to #{to_desc}"}
    end
  end

end
