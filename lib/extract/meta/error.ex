defmodule Extract.Meta.Error do

  alias Extract.Meta.Context


  @error_alias {:__aliases__, [alias: false], [:Extract, :Meta, :Error]}


  defmacro comptime(ctx, {f, c, args})
   when is_atom(f) and (is_list(args) or args == nil) do
    alias_ast = {:__aliases__, [alias: false], [:Extract, :Meta, :Error]}
    fun_name = String.to_atom("comptime_" <> Atom.to_string(f))
    aliased_fun = {:., [], [alias_ast, fun_name]}
    props_ast = quote do: Context.properties(unquote(ctx))
    args = if is_list(args), do: args, else: []
    _ast = {aliased_fun, c, args ++ [props_ast]}
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


  def comptime_bad_option(value, name, kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:bad_option, {tag, name}}
    message = "invalid #{desc}#{inspect name} option value: #{inspect value}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_bad_option(value, name, kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:bad_option, {tag, name}}
    message = "invalid #{desc}#{inspect name} option value: "
    quote do
      raise Extract.Error,
        reason: unquote(reason),
        message: unquote(message) <> inspect(unquote(value))
    end
  end


  def comptime_option_not_allowed(name, kv \\ []) do
    {tag, desc} = extract_info(kv, " for ", "")
    reason = {:option_not_allowed, {tag, name}}
    message = "option #{inspect name} not allowed#{desc}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_option_not_allowed(name, kv \\ []) do
    {tag, desc} = extract_info(kv, " for ", "")
    reason = {:option_not_allowed, {tag, name}}
    message = "option #{inspect name} not allowed#{desc}"
    quote do
      raise Extract.Error,
        reason: unquote(reason), message: unquote(message)
    end
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
                 <> "to #{inspect unquote(to)}"
    end
  end


  def comptime_undefined_value(kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:undefined_value, tag}
    message = "undefined #{desc}value"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_undefined_value(kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:undefined_value, tag}
    message = "undefined #{desc}value"
    quote do
      raise Extract.Error, reason: unquote(reason), message: unquote(message)
    end
  end


  def comptime_missing_value(kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:missing_value, tag}
    message = "missing #{desc}value"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_missing_value(kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:missing_value, tag}
    message = "missing #{desc}value"
    quote do
      raise Extract.Error, reason: unquote(reason), message: unquote(message)
    end
  end


  def comptime_value_not_allowed(value, kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:value_not_allowed, tag}
    message = "#{desc}value not allowed: #{Macro.to_string(value)}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_value_not_allowed(value, kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:value_not_allowed, tag}
    message = "#{desc}value not allowed: "
    quote do
      raise Extract.Error,
        reason: unquote(reason),
        message: unquote(message) <> inspect(unquote(value))
    end
  end


  def comptime_bad_value(value, kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:bad_value, {tag, :bad_type}}
    message = "bad #{desc}value: #{Macro.to_string(value)}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_bad_value(value, kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:bad_value, {tag, :bad_type}}
    message = "bad #{desc}value: "
    quote do
      raise Extract.Error,
        reason: unquote(reason),
        message: unquote(message) <> inspect(unquote(value))
    end
  end


  def comptime_value_too_big(value, max, kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:bad_value, {tag, :too_big}}
    message = "#{desc}value bigger than #{Macro.to_string(max)}: "
              <> "#{Macro.to_string(value)}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_value_too_big(value, max, kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:bad_value, {tag, :too_big}}
    message = "#{desc}value bigger than"
    quote do
      raise Extract.Error,
        reason: unquote(reason),
        message: "#{unquote(message)} #{inspect unquote(max)}: #{inspect unquote(value)}"
    end
  end


  def comptime_value_too_small(value, min, kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:bad_value, {tag, :too_small}}
    message = "#{desc}value smaller than #{Macro.to_string(min)}: "
              <> "#{Macro.to_string(value)}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_value_too_small(value, min, kv \\ []) do
    {tag, desc} = extract_info(kv)
    reason = {:bad_value, {tag, :too_small}}
    message = "#{desc}value smaller than"
    quote do
      raise Extract.Error,
        reason: unquote(reason),
        message: "#{unquote(message)} #{inspect unquote(min)}: #{inspect unquote(value)}"
    end
  end


  def comptime_distillation_error(value, kv \\ []) do
    {from_tag, to_tag, desc} = receipt_info(kv, " from ", "")
    reason = {:distillation_error, {from_tag, to_tag}}
    message = "error converting value#{desc}: #{Macro.to_string(value)}"
    raise Extract.Error, reason: reason, message: message
  end


  defmacro runtime_distillation_error(value, kv \\ []) do
    {from_tag, to_tag, desc} = receipt_info(kv, " from ", "")
    reason = {:distillation_error, {from_tag, to_tag}}
    message = "error converting value#{desc}: "
    quote do
      raise Extract.Error,
        reason: unquote(reason),
        message: unquote(message) <> inspect(unquote(value))
    end
  end


  defp extract_info(kv, prefix \\ "", postfix \\ " ") do
    case Keyword.fetch(kv, :extract_history) do
      :error -> {:unknwon, ""}
      {:ok, []} -> {:unknown, ""}
      {:ok, [{name, desc} | _]} -> {name, prefix <> desc <> postfix}
    end
  end


  defp receipt_info(kv, prefix, postfix) do
    case Keyword.fetch(kv, :receipt_history) do
      :error -> {:unknwon, :unknwon, ""}
      {:ok, []} -> {:unknown, :unknwon, ""}
      {:ok, [{{from, to}, desc} | _]} -> {from, to, prefix <> desc <> postfix}
    end
  end

end
