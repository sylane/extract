defmodule Extract.Pipeline do

  alias Extract.Meta.Context


  @default_undefined nil
  @default_missing nil


  defmacro __using__(_args) do
    quote location: :keep do
      import Extract.Pipeline, only: :macros
      require Extract.Meta.Context
      require Extract.Meta.Error
    end
  end


  defmacro pipeline(ast, ctx, body \\ [])

  defmacro pipeline(ast, kv, body) when is_list(kv) do
    block = Keyword.get(body, :do)
    env = Keyword.get(kv, :env)
    caller = Keyword.get(kv, :caller)
    ctx = quote location: :keep do
      Extract.Meta.Context.new(env: unquote(env), caller: unquote(caller))
    end
    compose(ast, ctx, block, finalize: true)
  end


  defmacro pipeline(ast, ctx, body) when is_tuple(ctx) do
    compose(ast, ctx, Keyword.get(body, :do))
  end


  defmacro condition(ast, ctx, {f, c, a}, body \\ []) do
    ast_var = Macro.var(:original_ast, __MODULE__)
    ctx_var = Macro.var(:original_ctx, __MODULE__)
    do_statments = compose(ast_var, ctx_var, body[:do])
    else_statments = compose(ast_var, ctx_var, body[:else])
    statments = quote location: :keep do
      fn
        (:do, unquote(ast_var), unquote(ctx_var)) ->
          unquote(do_statments)
        (:else, unquote(ast_var), unquote(ctx_var)) ->
          unquote(else_statments)
      end
    end
    {f, c, [ast, ctx, statments | a]}
  end


  defmacro branch(ast, ctx, format, body \\ []) do
    ctx_var = Macro.var(:original_ctx, __MODULE__)
    ast_var = Macro.var(:original_ast, __MODULE__)
    lookup = build_lookup(ast_var, ctx_var, Keyword.get(body, :do))
    else_block = protect(compose(ast_var, ctx_var, Keyword.get(body, :else)))
    quote location: :keep do
      unquote(ast_var) = unquote(ast)
      unquote(ctx_var) = unquote(ctx)
      choices = unquote(lookup)
      else_branch = unquote(else_block)
      case unquote(format) do
        format when is_atom(format) ->
          case {Keyword.fetch(choices, format), else_branch} do
            {{:ok, {:ok, result}}, _} -> result
            {{:ok, {:error, {error, stacktrace}}}, _} ->
              reraise error, stacktrace
            {:error, {:ok, result}} -> result
            {:error, {:error, {error, stacktrace}}} ->
              reraise error, stacktrace
          end
        format ->
          # FIXME: what it a :else block raises a compile-time exception ?
          {:ok, {else_ast, else_ctx}} = else_branch
          sub_ctxs = for {_, {:ok, {_, c}}} <- choices, do: c
          ctx = Context.merge(unquote(ctx_var), [else_ctx] ++ sub_ctxs)
          choices_ast = for {f, {:ok, {ast, _}}} <- choices do
            [choice_ast] = quote location: :keep do
              unquote(f) -> unquote(ast)
            end
            choice_ast
          end
          default_ast = quote location: :keep do
            _other -> unquote(else_ast)
          end
          all_choices_ast = choices_ast ++ default_ast
          ast = quote location: :keep do
            case unquote(format) do
              unquote(all_choices_ast)
            end
          end
          {ast, ctx}
      end
    end
  end


  defp compose(ast, ctx, statments, kv \\ [])

  defp compose(ast, ctx, nil, kv) do
    case Keyword.get(kv, :finalize, false) do
      true -> {:__block__, [], [ast]}
      false -> {:__block__, [], [{ast, ctx}]}
    end
  end

  defp compose(ast, ctx, {:__block__, block_ctx, statments}, kv) do
    statments = compose_statments(statments, ast, ctx)
    statment = {:__block__, block_ctx, statments}
    case Keyword.get(kv, :finalize, false) do
      false -> statment
      true ->
         quote location: :keep do
          {result, _} = unquote(statment)
          result
        end
    end
  end

  defp compose(ast, ctx, {f, c, a}, kv) do
    statment = {f, c, [ast, ctx | a]}
    case Keyword.get(kv, :finalize, false) do
      true ->
        quote location: :keep do
          {ast, ctx} = unquote(statment)
          ast
        end
      false -> statment
    end
  end


  defp compose_statments(statments, ast, ctx) do
    compose_statments(statments, ast, ctx, [])
  end


  defp compose_statments([{f, c, a}], ast, ctx, acc)
   when is_list(a) or is_nil(a) do
    args = if is_list(a), do: a, else: []
    statment = {f, c, [ast, ctx | args]}
    Enum.reverse(acc, [statment])
  end

  defp compose_statments([{f, c, a} | statments], ast, ctx, acc)
   when is_list(a) or is_nil(a) do
    ast_var = Macro.var(:ast, __MODULE__)
    ctx_var = Macro.var(:ctx, __MODULE__)
    args = if is_list(a), do: a, else: []
    statment = {f, c, [ast, ctx | args]}
    new_statment = quote location: :keep do
      {unquote(ast_var), unquote(ctx_var)} = unquote(statment)
    end
    compose_statments(statments, ast_var, ctx_var, [new_statment | acc])
  end


  defp build_lookup(_ast, _ctx, nil), do: []

  defp build_lookup(ast, ctx, {:__block__, _, statments}) do
    build_lookup(ast, ctx, statments)
  end

  defp build_lookup(ast, ctx, statments) when is_list(statments) do
    extract = fn
      {:->, _, [[k], {:__block__, _, _} = body]} when is_atom(k) ->
        {k, compose(ast, ctx, body)}
      {:->, _, [[k], {f, c, a}]} when is_atom(k) ->
        {k, {f, c, [ast, ctx | a]}}
      any ->
        raise Extract.Error,
          reason: :bad_branch_statement,
          message: "invalid branch statment: #{Macro.to_string(any)}"
    end
    keyed_protect = fn {k, ast} -> {k, protect(ast)} end
    Enum.map(Enum.map(statments, extract), keyed_protect)
  end


  defp protect(ast) do
    quote location: :keep do
      try do
        {:ok, unquote(ast)}
      rescue
        e in Extract.Error ->
          {:error, {e, System.stacktrace()}}
      end
    end
  end

end