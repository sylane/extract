defmodule Extract.Meta.Context do

  require Extract.Meta.Error

  alias Extract.Meta.Context
  alias Extract.Meta.Error


  defstruct [debug: nil,
             type_info: [],
             missing_value: nil,
             undefined_value: nil,
             encapsulated: false,
             may_raise: false,
             may_be_undefined: true,
             may_be_missing: false,
             macro_env: nil,
             caller_env: nil]


  def new(kv \\ []) do
    env = Keyword.get(kv, :env, nil)
    caller = Keyword.get(kv, :caller, nil)
    %Context{debug: debug_context(env, caller),
             macro_env: env, caller_env: caller}
  end


  def debug(%Context{debug: result}), do: result

  def push_type_info(%Context{type_info: type_info} = ctx, tag, desc)
   when is_atom(tag) and is_binary(desc) do
    %Context{ctx | type_info: [{tag, desc} | type_info]}
  end


  def properties(%Context{} = ctx) do
    [type_info: ctx.type_info]
  end


  def merge(%Context{} = ctx, ctxs) when is_list(ctxs) do
    %Context{ctx | encapsulated: merge_same(ctx, ctxs, :encapsulated),
                   may_raise: merge_any(ctx, ctxs, :may_raise),
                   may_be_undefined: merge_any(ctx, ctxs, :may_be_undefined),
                   may_be_missing: merge_any(ctx, ctxs, :may_be_missing)}
  end


  def undefined_value(%Context{} = ctx, value) do
    %Context{ctx | undefined_value: value}
  end

  def undefined_value(%Context{undefined_value: result}),  do: result


  def missing_value(%Context{} = ctx, value) do
    %Context{ctx | missing_value: value}
  end


  def missing_value(%Context{missing_value: result}),  do: result


  def encapsulated(%Context{} = ctx, flag \\ true) when is_boolean(flag) do
    %Context{ctx | encapsulated: flag}
  end


  def encapsulated?(%Context{encapsulated: result}),  do: result


  def may_raise(%Context{} = ctx, flag \\ true) when is_boolean(flag) do
    %Context{ctx | may_raise: flag}
  end


  def may_raise?(%Context{may_raise: result}),  do: result


  def may_be_undefined(%Context{} = ctx, flag \\ true) when is_boolean(flag) do
    %Context{ctx | may_be_undefined: flag}
  end


  def may_be_undefined?(%Context{may_be_undefined: result}),  do: result


  def may_be_missing(%Context{} = ctx, flag \\ true) when is_boolean(flag) do
    %Context{ctx | may_be_missing: flag}
  end


  def may_be_missing?(%Context{may_be_missing: result}),  do: result


  def eval_quoted(ctx, ast, bindings \\ [])

  def eval_quoted(%Context{caller_env: nil} = ctx, _ast, _bindings) do
    Error.comptime(ctx, error({:cannot_eval, :no_valler_env},
      "cannot eval quoted without the caller environment"))
  end

  def eval_quoted(%Context{caller_env: env}, ast, bindings) do
    Code.eval_quoted(ast, bindings, env)
  end


  defp debug_context(nil, nil), do: "Unknown Macro"

  defp debug_context(env, nil), do: call_from_env(env)

  defp debug_context(nil, caller) do
    "Unknown Macro used in #{call_from_env caller}"
  end

  defp debug_context(env, caller) do
    "#{call_from_env env} used in #{call_from_env caller}"
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


  defp merge_any(_ctx, contexts, field) do
    Enum.any?(contexts, fn %Context{} = c -> Map.get(c, field) end)
  end


  defp merge_same(ctx, contexts, field) do
    try do
      map = fn %Context{} = c -> Map.get(c, field) end
      reduce = fn same, same -> same
                  _new, _last -> raise :internal_error
      end
      Enum.reduce(Enum.map(contexts, map), reduce)
    rescue
      _ ->
        Error.comptime ctx,
          error({:context_merge_error, field},
            "multiple sub-contexts with different value for '#{field}' flag")
    end
  end

end
