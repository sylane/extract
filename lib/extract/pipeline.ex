defmodule Extract.Pipeline do

  alias Extract.Meta.Context


  @default_undefined nil
  @default_missing nil


  defmacro __using__(_args) do
    _ast = quote location: :keep do
      import Extract.Pipeline, only: :macros
      require Extract.Meta.Context
      require Extract.Meta.Error
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro is_comptime(ast) do
    case Macro.Env.in_guard?(__CALLER__) do
      true ->
        quote do
          is_number(unquote(ast))
          or is_atom(unquote(ast))
          or is_binary(unquote(ast))
          or (is_tuple(unquote(ast)) and tuple_size(unquote(ast)) == 2)
        end
      false ->
        quote do
          value = unquote(ast)
          is_number(value) or is_atom(value) or is_binary(value)
            or (is_tuple(value) and tuple_size(value) == 2)
        end
    end
  end


  defmacro pipeline(ast, ctx, body \\ [])

  defmacro pipeline(ast, kv, body) when is_list(kv) do
    env = Keyword.get(kv, :env)
    caller = Keyword.get(kv, :caller)
    ctx = quote location: :keep do
      Extract.Meta.Context.new(env: unquote(env), caller: unquote(caller))
    end
    pipe_ast = _pipeline(ast, ctx, body, finalize: true)
    case Keyword.get(kv, :debug, false) do
      false -> pipe_ast
      true ->
        quote do
          ast = unquote(pipe_ast)
          Extract.Meta.Context.debug(ast, unquote(ctx))
        end
    end
  end


  defmacro pipeline(ast, ctx, body) when is_tuple(ctx) do
    _pipeline(ast, ctx, body)
  end

  defmacro pipeline(ast, ctx, body) do
    throw {:unexpected, ast, ctx, body}
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
          # If there is some errors, be sure to update the context
          may_raise = (for {_, {:error, _}} <- choices, do: true) != []
          ctx = if may_raise do
            unquote(ctx_var)
              |> Context.merge([else_ctx] ++ sub_ctxs)
              |> Context.may_raise
          else
            unquote(ctx_var) |> Context.merge([else_ctx] ++ sub_ctxs)
          end
          choices_ast = for {f, choice} <- choices do
            case choice do
              {:ok, {ast, _}} ->
                [choice_ast] = quote location: :keep do
                  unquote(f) -> unquote(ast)
                end
                choice_ast
              {:error, {error, _stacktrace}} ->
                escaped_error = Macro.escape(error)
                [choice_ast] = quote location: :keep do
                  unquote(f) -> raise unquote(escaped_error)
                end
                choice_ast
            end
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


  defp _pipeline(ast, ctx, body, opts \\ []) do
    pipe_ast = compose(ast, ctx, Keyword.get(body, :do), opts)
    case Keyword.fetch(body, :rescue) do
      :error -> pipe_ast
      {:ok, block} ->
        var = Macro.var(:error, __MODULE__)
        rescue_ast = compose(var, ctx, block, opts)
        quote do
          try do
            unquote(pipe_ast)
          rescue
            error in Extract.Error ->
              unquote(var) = Macro.escape(error)
              unquote(rescue_ast)
          end
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