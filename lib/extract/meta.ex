defmodule Extract.Meta do

  use Extract.Pipeline

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
    case Options.validate(ctx, opts, allowed) do
      :ok -> {ast, ctx}
      {:error, {reason, message}} ->
        Error.comptime(ctx, error(reason, message))
    end
  end


  def allowed_value(ast, ctx, opts) do
    undefined_value = Context.undefined_value(ctx)
    missing_value = Context.missing_value(ctx)
    encapsulated = Context.encapsulated?(ctx)
    allow_missing = Options.get(ctx, opts, :allow_missing, false)
    may_be_missing = Context.may_be_missing?(ctx)
    allow_undefined = Options.get(ctx, opts, :allow_undefined, false)
    may_be_undefined = Context.may_be_undefined?(ctx)
    case Options.fetch(ctx, opts, :allowed) do
      :error -> {ast, ctx}
      {:ok, allowed} ->
        case {encapsulated, allow_missing, may_be_missing,
              allow_undefined, may_be_undefined, ast} do
          {false, _, _, true, true, ^undefined_value} ->
            # undefined at compile-time but it is allowed
            {ast, ctx}
          {false, _, _, false, true, ^undefined_value} ->
            # undefined at compile-time and it is forbidden
            Error.comptime(ctx, value_not_allowed(undefined_value))
          {false, true, true, _, _, ^missing_value} ->
            # missing at compile-time but it is allowed
            {ast, ctx}
          {false, false, true, _, _, ^missing_value} ->
            # missing at compile-time and it is forbidden
            Error.comptime(ctx, value_not_allowed(missing_value))
          {false, _, _, _, _, value} when is_comptime(value) ->
            # defined at compile time
            comptime_check_allowed(ctx, value, allowed)
          {false, _, false, _, false, ast} ->
            # cannot be undefined or missing
            runtime_check_allowed(ctx, ast, allowed)
          {false, false, true, true, true, ast} ->
            # may be missing and forbidden or undefined and allowed
            val_var = Macro.var(:value, __MODULE__)
            {chk_ast, chk_ctx} = runtime_check_allowed(ctx, val_var, allowed)
            {err_ast, [err_var]} = Error.runtime(ctx, value_not_allowed/1)
            ctx = chk_ctx |> Context.may_raise
            ast = quote location: :keep do
              case unquote(ast) do
                unquote(undefined_value) = result -> result
                unquote(missing_value) = unquote(err_var) -> unquote(err_ast)
                unquote(val_var) -> unquote(chk_ast)
              end
            end
            {ast, ctx}
          {false, true, true, false, true, ast} ->
            # may be missing and allowed or undefined and forbidden
            val_var = Macro.var(:value, __MODULE__)
            {chk_ast, chk_ctx} = runtime_check_allowed(ctx, val_var, allowed)
            {err_ast, [err_var]} = Error.runtime(ctx, value_not_allowed/1)
            ctx = chk_ctx |> Context.may_raise
            ast = quote location: :keep do
              case unquote(ast) do
                unquote(undefined_value) = unquote(err_var) -> unquote(err_ast)
                unquote(missing_value) = result -> result
                unquote(val_var) -> unquote(chk_ast)
              end
            end
            {ast, ctx}
          {false, false, true, false, true, ast} ->
            # may be missing or undefined both forbidden
            val_var = Macro.var(:value, __MODULE__)
            {chk_ast, chk_ctx} = runtime_check_allowed(ctx, val_var, allowed)
            {err_ast, [err_var]} = Error.runtime(ctx, value_not_allowed/1)
            ctx = chk_ctx |> Context.may_raise
            ast = quote location: :keep do
              case unquote(ast) do
                unquote(undefined_value) = unquote(err_var) -> unquote(err_ast)
                unquote(missing_value) = unquote(err_var) -> unquote(err_ast)
                unquote(val_var) -> unquote(chk_ast)
              end
            end
            {ast, ctx}
          {false, true, true, true, true, ast} ->
            # may be missing or undefined both allowed
            val_var = Macro.var(:value, __MODULE__)
            {chk_ast, chk_ctx} = runtime_check_allowed(ctx, val_var, allowed)
            ctx = chk_ctx |> Context.may_raise
            ast = quote location: :keep do
              case unquote(ast) do
                unquote(undefined_value) = result -> result
                unquote(missing_value) = result -> result
                unquote(val_var) -> unquote(chk_ast)
              end
            end
            {ast, ctx}
          {false, true, true, _, false, ast} ->
            # may be missing but it is allowed
            val_var = Macro.var(:value, __MODULE__)
            {chk_ast, chk_ctx} = runtime_check_allowed(ctx, val_var, allowed)
            ctx = chk_ctx |> Context.may_raise
            ast = quote location: :keep do
              case unquote(ast) do
                unquote(missing_value) = result -> result
                unquote(val_var) -> unquote(chk_ast)
              end
            end
            {ast, ctx}
          {false, false, true, _, false, ast} ->
            # may be missing and it is forbidden
            val_var = Macro.var(:value, __MODULE__)
            {chk_ast, chk_ctx} = runtime_check_allowed(ctx, val_var, allowed)
            {err_ast, [err_var]} = Error.runtime(ctx, value_not_allowed/1)
            ctx = chk_ctx |> Context.may_raise
            ast = quote location: :keep do
              case unquote(ast) do
                unquote(missing_value) = unquote(err_var) -> unquote(err_ast)
                unquote(val_var) -> unquote(chk_ast)
              end
            end
            {ast, ctx}
          {false, _, false, true, true, ast} ->
            # may be undefined but it is allowed
            val_var = Macro.var(:value, __MODULE__)
            {chk_ast, chk_ctx} = runtime_check_allowed(ctx, val_var, allowed)
            ctx = chk_ctx |> Context.may_raise
            ast = quote location: :keep do
              case unquote(ast) do
                unquote(undefined_value) = result -> result
                unquote(val_var) -> unquote(chk_ast)
              end
            end
            {ast, ctx}
          {false, _, false, false, true, ast} ->
            # may be undefined and it is forbidden
            val_var = Macro.var(:value, __MODULE__)
            {chk_ast, chk_ctx} = runtime_check_allowed(ctx, val_var, allowed)
            {err_ast, [err_var]} = Error.runtime(ctx, value_not_allowed/1)
            ctx = chk_ctx |> Context.may_raise
            ast = quote location: :keep do
              case unquote(ast) do
                unquote(undefined_value) = unquote(err_var) -> unquote(err_ast)
                unquote(val_var) -> unquote(chk_ast)
              end
            end
            {ast, ctx}
        end
    end
  end


  def defined?(ast, ctx, statments, opts) do
    undefined_value = Context.undefined_value(ctx)
    missing_value = Context.missing_value(ctx)
    encapsulated = Context.encapsulated?(ctx)
    allow_missing = Options.get(ctx, opts, :allow_missing, false)
    may_be_missing = Context.may_be_missing?(ctx)
    allow_undefined = Options.get(ctx, opts, :allow_undefined, false)
    may_be_undefined = Context.may_be_undefined?(ctx)
    default = Options.fetch(ctx, opts, :default)
    do_ctx = ctx
      |> Context.encapsulated(false)
      |> Context.may_be_missing(false)
      |> Context.may_be_undefined(false)
    else_ctx = ctx |> Context.encapsulated(false)
    default_ctx = ctx
      |> Context.encapsulated(false)
      |> Context.may_be_undefined(false)
      |> Context.may_be_missing(false)
    case {encapsulated, allow_missing, may_be_missing,
          allow_undefined, may_be_undefined, default, ast} do
      {false, _, _, true, true, :error, ^undefined_value} ->
        # undefined at compile-time without default value but it is allowed
        statments.(:else, undefined_value, else_ctx)
      {false, _, _, false, true, :error, ^undefined_value} ->
        # undefined at compile-time without default value and it is forbidden
        Error.comptime(ctx, undefined_value)
      {false, _, _, _, true, {:ok, default}, ^undefined_value} ->
        # undefined at compile-time with default value
        statments.(:else, default, default_ctx)
      {false, true, true, _, _, :error, ^missing_value} ->
        # missing at compile-time without default value but it is allowed
        statments.(:else, missing_value, else_ctx)
      {false, false, true, _, _, :error, ^missing_value} ->
        # missing at compile-time without default value and it is forbidden
        Error.comptime(ctx, missing_value)
      {false, _, true, _, _, {:ok, default}, ^missing_value} ->
        # missing at compile-time with default value
        statments.(:else, default, default_ctx)
      {false, _, _, _, _, _, value} when is_comptime(value) ->
        # defined at compile time
        statments.(:do, value, do_ctx)
      {false, _, _, _, _, _, ast} when is_list(ast) ->
        # list cannot be undefined or missing
        statments.(:do, ast, do_ctx)
      {false, _, _, _, _, _, {type, _, _} = ast}
       when type == :{} or type == :%{} ->
        # tuples or maps cannot be undefined or missing
        statments.(:do, ast, do_ctx)
      {false, _, true, _, true, {:ok, default}, ast} ->
        # may be missing or undefined but there is a default value
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, default, default_ctx)
        result_ctx = Context.merge(ctx, [do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(else_ast)
            unquote(missing_value) -> unquote(else_ast)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, result_ctx}
      {false, false, true, true, true, :error, ast} ->
        # may be missing and forbidden or undefined and allowed
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, undefined_value, else_ctx)
        error = Error.runtime(ctx, missing_value)
        ctx = ctx |> Context.merge([do_ctx, else_ctx]) |> Context.may_raise
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(else_ast)
            unquote(missing_value) -> unquote(error)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, true, true, false, true, :error, ast} ->
        # may be missing and allowed or undefined and forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, missing_value, else_ctx)
        error = Error.runtime(ctx, undefined_value)
        ctx = ctx |> Context.merge([do_ctx, else_ctx]) |> Context.may_raise
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(error)
            unquote(missing_value) -> unquote(else_ast)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, false, true, false, true, :error, ast} ->
        # may be missing or undefined both forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        undef_error = Error.runtime(ctx, undefined_value)
        miss_error = Error.runtime(ctx, missing_value)
        ctx = do_ctx |> Context.may_raise
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(undef_error)
            unquote(missing_value) -> unquote(miss_error)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, true, true, true, true, :error, ast} ->
        # may be missing or undefined both allowed without default value
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {undef_ast, undef_ctx} = statments.(:else, undefined_value, else_ctx)
        {miss_ast, miss_ctx} = statments.(:else, missing_value, else_ctx)
        ctx = ctx |> Context.merge([do_ctx, undef_ctx, miss_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(undef_ast)
            unquote(missing_value) -> unquote(miss_ast)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, true, true, _, false, :error, ast} ->
        # may be missing without default value but it is allowed
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, missing_value, else_ctx)
        ctx = ctx |> Context.merge([do_ctx, else_ctx])
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
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, default, default_ctx)
        ctx = ctx |> Context.merge([do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(missing_value) -> unquote(else_ast)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, false, true, _, false, :error, ast} ->
        # may be missing without default value and it is forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        error = Error.runtime(ctx, missing_value)
        ctx = do_ctx |> Context.may_raise
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(missing_value) -> unquote(error)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, _, false, true, true, :error, ast} ->
        # may be undefined without default value but it is allowed
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, undefined_value, else_ctx)
        ctx = ctx |> Context.merge([do_ctx, else_ctx])
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
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, default, default_ctx)
        ctx = ctx |> Context.merge([do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(else_ast)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {false, _, false, false, true, :error, ast} ->
        # may be undefined without default value and it is forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        error = Error.runtime(ctx, undefined_value)
        ctx = do_ctx |> Context.may_raise
        ast = quote location: :keep do
          case unquote(ast) do
            unquote(undefined_value) -> unquote(error)
            unquote(val_var) -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, _, _, true, true, :error, :undefined} ->
        # undefined at compile-time without default value but it is allowed
        statments.(:else, undefined_value, else_ctx)
      {true, _, _, false, true, :error, :undefined} ->
        # undefined at compile-time without default value and it is forbidden
        Error.comptime(ctx, undefined_value)
      {true, _, _, _, true, {:ok, default}, :undefined} ->
        # undefined at compile-time with default value
        statments.(:else, default, default_ctx)
      {true, true, true, _, _, :error, :missing} ->
        # missing at compile-time without default value but it is allowed
        statments.(:else, missing_value, else_ctx)
      {true, false, true, _, _, :error, :missing} ->
        # missing at compile-time without default value and it is forbidden
        Error.comptime(ctx, missing_value)
      {true, _, true, _, _, {:ok, default}, :missing} ->
        # missing at compile-time with default value
        statments.(:else, default, default_ctx)
      {true, _, _, _, _, _, {:value, value}} ->
        # defined at compile time
        statments.(:do, value, do_ctx)
      {true, _, false, _, false, _, ast} ->
        # cannot be undefined or missing, just unpack the value
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        quote location: :keep do
          {:value, unquote(val_var)} = unquote(ast)
          unquote(do_ast)
        end
      {true, _, true, _, true, {:ok, default}, ast} ->
        # may be missing or undefined but there is a default value
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, default, default_ctx)
        ctx = ctx |> Context.merge([do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(else_ast)
            :missing -> unquote(else_ast)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, false, true, true, true, :error, ast} ->
        # may be missing and forbidden or undefined and allowed
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, undefined_value, else_ctx)
        error = Error.runtime(ctx, missing_value)
        ctx = ctx |> Context.merge([do_ctx, else_ctx]) |> Context.may_raise
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(else_ast)
            :missing -> unquote(error)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, true, true, false, true, :error, ast} ->
        # may be missing and allowed or undefined and forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, missing_value, else_ctx)
        error = Error.runtime(ctx, undefined_value)
        ctx = ctx |> Context.merge([do_ctx, else_ctx]) |> Context.may_raise
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(error)
            :missing -> unquote(else_ast)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, false, true, false, true, :error, ast} ->
        # may be missing or undefined both forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        undef_error = Error.runtime(ctx, undefined_value)
        miss_error = Error.runtime(ctx, missing_value)
        ctx = do_ctx |> Context.may_raise
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(undef_error)
            :missing -> unquote(miss_error)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, true, true, true, true, :error, ast} ->
        # may be missing or undefined both forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {undef_ast, undef_ctx} = statments.(:else, undefined_value, else_ctx)
        {miss_ast, miss_ctx} = statments.(:else, missing_value, else_ctx)
        ctx = ctx |> Context.merge([do_ctx, undef_ctx, miss_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(undef_ast)
            :missing -> unquote(miss_ast)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, true, true, _, false, :error, ast} ->
        # may be missing without default value but it is allowed
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, missing_value, else_ctx)
        ctx = ctx |> Context.merge([do_ctx, else_ctx])
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
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, default, default_ctx)
        ctx = ctx |> Context.merge([do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            :missing -> unquote(else_ast)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, false, true, _, false, :error, ast} ->
        # may be missing without default value and it is forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        error = Error.runtime(ctx, missing_value)
        ctx = do_ctx |> Context.may_raise
        ast = quote location: :keep do
          case unquote(ast) do
            :missing -> unquote(error)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, _, false, true, true, :error, ast} ->
        # may be undefined without default value but it is allowed
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, undefined_value, else_ctx)
        ctx = ctx |> Context.merge([do_ctx, else_ctx])
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
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        {else_ast, else_ctx} = statments.(:else, default, default_ctx)
        ctx = ctx |> Context.merge([do_ctx, else_ctx])
        ast = quote location: :keep do
          case unquote(ast) do
            :undefined -> unquote(else_ast)
            {:value, unquote(val_var)} -> unquote(do_ast)
          end
        end
        {ast, ctx}
      {true, _, false, false, true, :error, ast} ->
        # may be undefined without default value and it is forbidden
        val_var = Macro.var(:value, __MODULE__)
        {do_ast, do_ctx} = statments.(:do, val_var, do_ctx)
        error = Error.runtime(ctx, undefined_value)
        ctx = do_ctx |> Context.may_raise
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
    undefined_value = Context.undefined_value(ctx)
    missing_value = Context.missing_value(ctx)
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
            e in Extract.Error ->
              {:error, e.reason}
          end
        end
        {ast, ctx}
    end
  end


  def comptime_rescue(error, ctx) do
    case error do
      {:%{}, _, kv} -> {{:error, Keyword.get(kv, :reason, :unknown)}, ctx}
      value when is_comptime(value) -> {{:error, value}, ctx}
      error_ast ->
        ast = quote do
          {:error, Map.get(unquote(error_ast), :reason)}
        end
        {ast, ctx}
    end
  end


  def comptime_rescue!(error, ctx) do
    ast = quote do
      raise unquote(error)
    end
    {ast, ctx}
  end


  defp comptime_check_allowed(ctx, value, nil) do
    {value, ctx}
  end

  defp comptime_check_allowed(ctx, value, allowed) when is_list(allowed) do
    case Enum.member?(allowed, value) do
      true -> {value, ctx}
      false ->
        raise Error.comptime(ctx, value_not_allowed(value))
    end
  end

  defp comptime_check_allowed(ctx, value, allowed) when is_map(allowed) do
    case Map.has_key?(allowed, value) do
      true -> {value, ctx}
      false ->
        raise Error.comptime(ctx, value_not_allowed(value))
    end
  end

  defp comptime_check_allowed(ctx, _value, allowed) do
    Error.comptime(ctx, error({:bad_option, {:allowed, allowed}},
      "invalid 'allowed' option value: #{inspect allowed}"))
  end


  defp runtime_check_allowed(ctx, ast, nil) do
    {ast, ctx}
  end

  defp runtime_check_allowed(ctx, ast, allowed) when is_list(allowed) do
    {error_ast, [error_var]} = Error.runtime(ctx, value_not_allowed/1)
    ast = quote do
      unquote(error_var) = unquote(ast)
      allowed = unquote(allowed)
      case Enum.member?(allowed, unquote(error_var)) do
        true -> unquote(error_var)
        false -> unquote(error_ast)
      end
    end
    {ast, Context.may_raise(ctx)}
  end

  defp runtime_check_allowed(ctx, ast, allowed) when is_map(allowed) do
    {error_ast, [error_var]} = Error.runtime(ctx, value_not_allowed/1)
    allowed_keys = Map.keys(allowed)
    ast = quote do
      unquote(error_var) = unquote(ast)
      allowed = unquote(allowed_keys)
      case Enum.member?(allowed, unquote(error_var)) do
        true -> unquote(error_var)
        false -> unquote(error_ast)
      end
    end
    {ast, Context.may_raise(ctx)}
  end

  defp runtime_check_allowed(ctx, _value, allowed) do
    Error.comptime(ctx, error({:bad_option, {:allowed, allowed}},
      "invalid 'allowed' option value: #{inspect allowed}"))
  end

end