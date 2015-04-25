defmodule Extract.Meta.Context do

  alias Extract.Meta.Context


  defstruct [missing_value: nil,
             undefined_value: nil,
             encapsulated: false,
             may_raise: false,
             may_be_undefined: true,
             may_be_missing: false,
             current_format: nil,
             extract_history: [],
             receipt_history: [],
             macro_env: nil,
             caller_env: nil]


  def new(kv \\ []) do
    env = Keyword.get(kv, :env, nil)
    caller = Keyword.get(kv, :caller, nil)
    %Context{macro_env: env, caller_env: caller}
  end


  def debug(ast, %Context{macro_env: env, caller_env: caller}, opts \\ []) do
    Extract.Meta.Debug.ast(ast, [{:env, env}, {:caller, caller} | opts])
  end


  def set_format(%Context{} = ctx, name) when is_atom(name) do
    %Context{ctx | current_format: name}
  end


  def current_format(%Context{current_format: name}), do: name


  def push_extract(%Context{extract_history: history} = ctx, name, desc)
   when is_atom(name) and is_binary(desc) do
    %Context{ctx | extract_history: [{name, desc} | history]}
  end


  def push_receipt(%Context{receipt_history: history} = ctx, from, to, desc)
   when is_atom(from) and is_atom(to) and is_binary(desc) do
    %Context{ctx | receipt_history: [{{from, to}, desc} | history]}
  end


  def properties(%Context{} = ctx) do
    [current_format: ctx.current_format,
     extract_history: ctx.extract_history,
     receipt_history: ctx.receipt_history]
  end


  def merge(%Context{} = ctx, ctxs) when is_list(ctxs) do
    %Context{ctx | encapsulated: merge_equal(ctx, ctxs, :encapsulated),
                   may_raise: merge_any(ctx, ctxs, :may_raise),
                   may_be_undefined: merge_any(ctx, ctxs, :may_be_undefined),
                   may_be_missing: merge_any(ctx, ctxs, :may_be_missing),
                   current_format: merge_if_same(ctx, ctxs, :current_format)}
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

  def eval_quoted(%Context{caller_env: nil}, _ast, _bindings) do
    msg =  "cannot eval quoted without the caller environment"
    raise CompileError, description: msg, file: "", line: 0
  end

  def eval_quoted(%Context{caller_env: env}, ast, bindings) do
    Code.eval_quoted(ast, bindings, env)
  end


  defp merge_any(_ctx, contexts, field) do
    Enum.any?(contexts, fn %Context{} = c -> Map.get(c, field) end)
  end


  defp merge_equal(ctx, contexts, field) do
    try do
      map = fn %Context{} = c -> Map.get(c, field) end
      reduce = fn same, same -> same
                  _new, _last -> raise Extract.Error
      end
      subtypes = for c <- contexts do
        Keyword.get(Context.properties(c), :type_info)
      end
      type = Keyword.get(Context.properties(ctx), :type_info)
      Enum.reduce(Enum.map(contexts, map), reduce)
    rescue
      Enum.EmptyError -> Map.get(ctx, field)
      Extract.Error ->
        msg = "multiple sub-contexts with different value for '#{field}' flag"
        raise CompileError, description: msg, file: "", line: 0
    end
  end


  defp merge_if_same(ctx, contexts, field, default \\ nil) do
    try do
      map = fn %Context{} = c -> {:ok, Map.get(c, field)} end
      reduce = fn {:ok, value}, {:ok, value} -> {:ok, value}
                  {:ok, nil}, {:ok, value}  -> {:ok, value}
                  {:ok, value}, {:ok, nil} -> {:ok, value}
                  {:ok, _new}, {:ok, _last} -> :error
                  :error, _any -> :error
                  _any, :error -> :error
      end
      subtypes = for c <- contexts do
        Keyword.get(Context.properties(c), :type_info)
      end
      type = Keyword.get(Context.properties(ctx), :type_info)
      case Enum.reduce(Enum.map(contexts, map), reduce) do
        {:ok, value} -> value
        :error -> default
      end
    rescue
      Enum.EmptyError -> Map.get(ctx, field)
      Extract.Error ->
        msg = "multiple sub-contexts with different value for '#{field}' flag"
        raise CompileError, description: msg, file: "", line: 0
    end
  end

end
