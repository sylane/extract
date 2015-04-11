defmodule Extract.Meta do

  require Extract.Meta.Context
  require Extract.Meta.Options
  require Extract.Meta.Error

  alias Extract.Meta.Context
  alias Extract.Meta.Options
  alias Extract.Meta.Error


  def type_info(ast, ctx, tag, description) do
    {ast, Context.push_type_info(ctx, tag, description)}
  end


  def allowed_options(ast, ctx, opts, allowed) do
    case Options.validate(opts, allowed) do
      :ok -> {ast, ctx}
      {:error, {reason, message}} ->
        Error.comptime(ctx, error(reason, message))
    end
  end


  def defined?(ast, ctx, statments, opts) do
    undefined_value = Context.undefined(ctx)
    missing_value = Context.missing(ctx)
    encapsulated = Context.encapsulated?(ctx)
    allow_missing = Options.allow_missing(opts)
    may_be_missing = Context.may_be_missing?(ctx)
    allow_undefined = Options.allow_undefined(opts)
    may_be_undefined = Context.may_be_undefined?(ctx)
    default = Options.default(opts)
    ctx = Context.encapsulated(ctx, false)
    case {encapsulated, allow_missing, may_be_missing,
          allow_undefined, may_be_undefined, default, ast} do
      {false, _, _, true, true, nil, ^undefined_value} ->
        # undefined at compile-time without default value but it is allowed
        statments.(:else, undefined_value, ctx)
      {false, _, _, false, true, nil, ^undefined_value} ->
        # undefined at compile-time without default value and it is forbidden
        Error.comptime(ctx, undefined_value)
      {false, _, _, _, true, {:ok, default}, ^undefined_value} ->
        # undefined at compile-time with default value
        statments.(:else, default, ctx)
      {false, true, true, _, _, nil, ^missing_value} ->
        # missing at compile-time without default value but it is allowed
        statments.(:else, missing_value, ctx)
      {false, false, true, _, _, nil, ^missing_value} ->
        # missing at compile-time without default value and it is forbidden
        Error.comptime(ctx, missing_value)
      {false, _, true, _, _, {:ok, default}, ^missing_value} ->
        # missing at compile-time with default value
        statments.(:else, default, ctx)
      {false, _, _, _, _, _, value}
       when is_atom(value) or is_number(value) or is_binary(value) ->
        # defined at compile time
        statments.(:do, value, ctx)
      {false, _, false, _, false, _, ast} ->
        # cannot be undefined or missing
        statments.(:do, ast, ctx)
      {false, _, true, _, true, {:ok, default}, ast} ->
        # may be missing or undefined but there is a default value
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, default, ctx)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(else_ast)
            unquote(missing_value) -> unquote(else_ast)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, false, true, true, true, nil, ast} ->
        # may be missing and forbidden or undefined and allowed
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, undefined_value, ctx)
        {error, _} = Error.runtime(ctx, &missing_value/0)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(else_ast)
            unquote(missing_value) -> unquote(error)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, true, true, false, true, nil, ast} ->
        # may be missing and allowed or undefined and forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, missing_value, ctx)
        {error, _} = Error.runtime(ctx, &undefined_value/0)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(error)
            unquote(missing_value) -> unquote(else_ast)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, false, true, false, true, nil, ast} ->
        # may be missing or undefined both forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, ctx} = statments.(:do, val_var, ctx)
        {undef_error, _} = Error.runtime(ctx, &undefined_value/0)
        {miss_error, _} = Error.runtime(ctx, &missing_value/0)
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(undef_error)
            unquote(missing_value) -> unquote(miss_error)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, true, true, true, true, nil, ast} ->
        # may be missing or undefined both allowed without default value
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {undef_ast, undef_ctx} = statments.(:else, undefined_value, ctx)
        {miss_ast, miss_ctx} = statments.(:else, missing_value, ctx)
        ctx = Context.merge(ctx, [do_ctx, undef_ctx, miss_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(undef_ast)
            unquote(missing_value) -> unquote(miss_ast)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, true, true, _, false, nil, ast} ->
        # may be missing without default value but it is allowed
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, missing_value, ctx)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(missing_value) -> unquote(else_ast)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, _, true, _, false, {:ok, default}, ast} ->
        # may be missing with default value
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, default, ctx)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(missing_value) -> unquote(else_ast)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, false, true, _, false, nil, ast} ->
        # may be missing without default value and it is forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, ctx} = statments.(:do, val_var, ctx)
        {error, _} = Error.runtime(ctx, &missing_value/0)
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(missing_value) -> unquote(error)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, _, false, true, true, nil, ast} ->
        # may be undefined without default value but it is allowed
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, undefined_value, ctx)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(else_ast)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, _, false, _, true, {:ok, default}, ast} ->
        # may be undefined with default value
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, default, ctx)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(else_ast)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, _, false, false, true, nil, ast} ->
        # may be undefined without default value and it is forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, ctx} = statments.(:do, val_var, ctx)
        {error, _} = Error.runtime(ctx, &undefined_value/0)
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(error)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, _, _, true, true, nil, :undefined} ->
        # undefined at compile-time without default value but it is allowed
        statments.(:else, undefined_value, ctx)
      {true, _, _, false, true, nil, :undefined} ->
        # undefined at compile-time without default value and it is forbidden
        Error.comptime(ctx, undefined_value)
      {true, _, _, _, true, {:ok, default}, :undefined} ->
        # undefined at compile-time with default value
        statments.(:else, default, ctx)
      {true, true, true, _, _, nil, :missing} ->
        # missing at compile-time without default value but it is allowed
        statments.(:else, missing_value, ctx)
      {true, false, true, _, _, nil, :missing} ->
        # missing at compile-time without default value and it is forbidden
        Error.comptime(ctx, missing_value)
      {true, _, true, _, _, {:ok, default}, :missing} ->
        # missing at compile-time with default value
        statments.(:else, default, ctx)
      {true, _, _, _, _, _, {:value, value}} ->
        # defined at compile time
        statments.(:do, value, ctx)
      {true, _, false, _, false, _, ast} ->
        # cannot be undefined or missing, just unpack the value
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, ctx} = statments.(:do, val_var, ctx)
        quote location: :keep do
          {:value, unquote(val_var)} = unquote(ast)
          unquote(do_ast)
        end
      {true, _, true, _, true, {:ok, default}, ast} ->
        # may be missing or undefined but there is a default value
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, default, ctx)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(else_ast)
            :missing -> unquote(else_ast)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, false, true, true, true, nil, ast} ->
        # may be missing and forbidden or undefined and allowed
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, undefined_value, ctx)
        {error, _} = Error.runtime(ctx, &missing_value/0)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(else_ast)
            :missing -> unquote(error)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
      {true, true, true, false, true, nil, ast} ->
        # may be missing and allowed or undefined and forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, missing_value, ctx)
        {error, _} = Error.runtime(ctx, &undefined_value/0)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(error)
            :missing -> unquote(else_ast)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, false, true, false, true, nil, ast} ->
        # may be missing or undefined both forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, ctx} = statments.(:do, val_var, ctx)
        {undef_error, _} = Error.runtime(ctx, &undefined_value/0)
        {miss_error, _} = Error.runtime(ctx, &missing_value/0)
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(undef_error)
            :missing -> unquote(miss_error)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, true, true, true, true, nil, ast} ->
        # may be missing or undefined both forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {undef_ast, undef_ctx} = statments.(:else, undefined_value, ctx)
        {miss_ast, miss_ctx} = statments.(:else, missing_value, ctx)
        ctx = Context.merge(ctx, [do_ctx, undef_ctx, miss_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(undef_ast)
            :missing -> unquote(miss_ast)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, true, true, _, false, nil, ast} ->
        # may be missing without default value but it is allowed
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, missing_value, ctx)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            :missing -> unquote(else_ast)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, _, true, _, false, {:ok, default}, ast} ->
        # may be missing with default value
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, default, ctx)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            :missing -> unquote(else_ast)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, false, true, _, false, nil, ast} ->
        # may be missing without default value and it is forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, ctx} = statments.(:do, val_var, ctx)
        {error, _} = Error.runtime(ctx, &missing_value/0)
        ast = quote location: :keep do
          case unquote(ast) do
            :missing -> unquote(error)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, _, false, true, true, nil, ast} ->
        # may be undefined without default value but it is allowed
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, undefined_value, ctx)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(else_ast)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, _, false, _, true, {:ok, default}, ast} ->
        # may be undefined with default value
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, ctx)
        {else_ast, else_ctx} = statments.(:else, default, ctx)
        ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(else_ast)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, _, false, false, true, nil, ast} ->
        # may be undefined without default value and it is forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, ctx} = statments.(:do, val_var, ctx)
        {error, _} = Error.runtime(ctx, &undefined_value/0)
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(error)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
    end
  end


  def terminate!(ast, ctx) do
    undefined_value = Context.undefined(ctx)
    missing_value = Context.missing(ctx)
    encapsulated = Context.encapsulated?(ctx)
    may_be_undefined = Context.may_be_undefined?(ctx)
    may_be_missing = Context.may_be_missing?(ctx)
    ast = case {encapsulated, may_be_undefined, may_be_missing, ast} do
      {false, _, _, ast} -> ast
      {true, _, _, {:value, value}} -> value
      {true, true, _, :undefined} -> undefined_value
      {true, _, true, :missing} -> missing_value
      {true, false, false, ast} ->
        quote location: :keep do
          {:value, value} = unquote(ast)
          value
        end
      {true, true, false, ast} ->
        quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(undefined_value)
            {:value, value} -> value
          end
        end
      {true, false, true, ast} ->
        quote location: :keep do
          case unquote(ast) do
            :missing -> unquote(missing_value)
            {:value, value} -> value
          end
        end
      {true, true, true, ast} ->
        quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(undefined_value)
            :missing -> unquote(missing_value)
            {:value, value} -> value
          end
        end
    end
    {ast, ctx}
  end


  def terminate(ast, ctx) do
    {ast, ctx} = terminate!(ast, ctx)
    case Context.may_raise?(ctx) do
      false -> {{:ok, ast}, ctx}
      true ->
        ast = quote location: :keep do
          try do
            {:ok, unquote(ast)}
          rescue
            e in Extract.Error -> {:error, e.reason}
          end
        end
        {ast, ctx}
    end
  end

end