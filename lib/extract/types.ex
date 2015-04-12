defmodule Extract.Types do

  use Extract.Pipeline

  alias Extract.Meta
  alias Extract.Meta.Error
  alias Extract.Meta.Options
  alias Extract.Meta.Context
  alias Extract.Util


  defmacro __using__(_args) do
    quote do
      require Extract.Meta
      require Extract.Meta.Error
      require Extract.Meta.Options
      require Extract.Util
      require Extract.Valid
      require Extract.Trans
    end
  end


  defmacro validate(value, format, opts \\ []) do
    pipeline value, env: __ENV__, caller: __CALLER__ do
      Meta.allowed_options opts,
        [:optional, :allow_undefined, :allow_missing,
         :default, :allowed, :min, :max]
      _meta_validate format, opts
      Meta.terminate
      Util.debug
    end
  end


  defmacro validate!(value, format, opts \\ []) do
    pipeline value, env: __ENV__, caller: __CALLER__ do
      _meta_validate format, opts
      Meta.terminate!
      Util.debug
    end
  end


  defmacro types() do
    [:undefined, :atom, :boolean, :integer, :float, :number, :string, :binary]
  end


  defp _meta_validate(ast, ctx, format, opts) do
    pipeline ast, ctx do
      branch format do
        :undefined ->
          Meta.type_info(:undefined, "undefined")
          _meta_validate_undefined opts
        :atom ->
          Meta.type_info(:atom, "atom")
          condition Meta.defined?(opts) do
            _meta_validate_atom opts
            Meta.allowed_value opts
          end
        :boolean ->
          Meta.type_info(:boolean, "boolean")
          condition Meta.defined?(opts) do
            _meta_validate_boolean opts
            Meta.allowed_value opts
          end
        :integer ->
          Meta.type_info(:integer, "integer")
          condition Meta.defined?(opts) do
            _meta_validate_number opts, :is_integer
            Meta.allowed_value opts
          end
        :float ->
          Meta.type_info(:float, "float")
          condition Meta.defined?(opts) do
            _meta_validate_number opts, :is_float
            Meta.allowed_value opts
          end
        :number ->
          Meta.type_info(:number, "number")
          condition Meta.defined?(opts) do
            _meta_validate_number opts
            Meta.allowed_value opts
          end
        :string ->
          Meta.type_info(:string, "string")
          condition Meta.defined?(opts) do
            _meta_validate_string opts
            Meta.allowed_value opts
          end
        :binary ->
          Meta.type_info(:binary, "binary")
          condition Meta.defined?(opts) do
            _meta_validate_binary opts
            Meta.allowed_value opts
          end
      end
    end
  end


  defp _meta_validate_undefined(ast, ctx, _opts) do
    undefined_value = Context.undefined_value(ctx)
    {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
    case ast do
      ^undefined_value -> {undefined_value, ctx}
      ast ->
        ast = quote do
          case unquote(ast) do
            unquote(undefined_value) = result -> result
            unquote(bad_var) -> unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
    end
  end


  defp _meta_validate_atom(value, ctx, _opts) when is_atom(value) do
    {value, ctx}
  end

  defp _meta_validate_atom(value, ctx, _opts)
   when is_number(value) or is_binary(value) do
    Error.comptime(ctx, bad_value(value))
  end

  defp _meta_validate_atom(ast, ctx, _opts) do
    {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
    ast = quote do
      case unquote(ast) do
        value when is_atom(value) -> value
        unquote(bad_var) -> unquote(bad_ast)
      end
    end
    {ast, Context.may_raise(ctx)}
  end


  defp _meta_validate_boolean(value, ctx, _opts) when is_boolean(value) do
    {value, ctx}
  end

  defp _meta_validate_boolean(value, ctx, _opts)
   when is_atom(value) or is_number(value) or is_binary(value) do
    Error.comptime(ctx, bad_value(value))
  end

  defp _meta_validate_boolean(ast, ctx, _opts) do
    {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
    ast = quote do
      case unquote(ast) do
        value when is_boolean(value) -> value
        unquote(bad_var) -> unquote(bad_ast)
      end
    end
    {ast, Context.may_raise(ctx)}
  end


  defp _meta_validate_number(ast, ctx, opts, guard_name \\ :is_number) do
    min = Options.fetch(ctx, opts, :min)
    max = Options.fetch(ctx, opts, :max)
    var = Macro.var(:value, __MODULE__)
    guard = {guard_name, [context: Elixir, import: Kernel], [var]}
    {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
    {small_ast, [small_var]} = Error.runtime(ctx, value_too_small(min)/1)
    {big_ast, [big_var]} = Error.runtime(ctx, value_too_big(max)/1)
    case {apply(Kernel, guard_name, [ast]), ast, min, max} do
      {true, num, :error, :error} -> {num, ctx}
      {true, num, {:ok, min}, :error}
       when num >= min -> {num, ctx}
      {true, num, {:ok, min}, :error} ->
        Error.comptime(ctx, value_too_small(num, min))
      {true, num, :error, {:ok, max}}
       when num <= max -> {num, ctx}
      {true, num, :error, {:ok, max}} ->
        Error.comptime(ctx, value_too_big(num, max))
      {true, num, {:ok, min}, {:ok, max}}
       when num >= min and num <= max -> {num, ctx}
      {true, num, {:ok, min}, {:ok, _max}}
       when num >= min-> {num, ctx}
        Error.comptime(ctx, value_too_big(num. max))
      {true, num, {:ok, min}, {:ok, _max}} ->
        Error.comptime(ctx, value_too_small(num, min))
      {false, value, _, _}
       when is_atom(value) or is_number(value) or is_binary(value) ->
        Error.comptime(ctx, bad_value(value))
      {false, ast, :error, :error} ->
        {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
        ast = quote do
          case unquote(ast) do
            unquote(var) when unquote(guard) ->
              unquote(var)
            unquote(bad_var) ->
              unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
      {false, ast, {:ok, min}, :error} ->
        ast = quote do
          case unquote(ast) do
            unquote(var) when unquote(guard)
             and unquote(var) >= unquote(min) ->
              unquote(var)
            unquote(small_var)
             when is_integer(unquote(small_var)) ->
              unquote(small_ast)
            unquote(bad_var) ->
              unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
      {false, ast, :error, {:ok, max}} ->
        ast = quote do
          case unquote(ast) do
            unquote(var) when unquote(guard)
             and unquote(var) <= unquote(max) ->
              unquote(var)
            unquote(big_var) when is_integer(unquote(big_var)) ->
              unquote(big_ast)
            unquote(bad_var) ->
              unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
      {false, ast, {:ok, min}, {:ok, max}} ->
        ast = quote do
          case unquote(ast) do
            unquote(var) when unquote(guard)
             and unquote(var) >= unquote(min)
             and unquote(var) <= unquote(max) ->
              unquote(var)
            unquote(big_var) when is_integer(unquote(big_var))
             and unquote(big_var) >= unquote(min) ->
              unquote(big_ast)
            unquote(small_var) when is_integer(unquote(small_var)) ->
              unquote(small_ast)
            unquote(bad_var) ->
              unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
    end
  end


  defp _meta_validate_string(value, ctx, _opts) when is_binary(value) do
    case String.valid?(value) do
      true -> {value, ctx}
      false ->
        Error.comptime(ctx, bad_value(value))
    end
  end

  defp _meta_validate_string(value, ctx, _opts)
   when is_atom(value) or is_number(value) do
    Error.comptime(ctx, bad_value(value))
  end

  defp _meta_validate_string(ast, ctx, _opts) do
    {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
    ast = quote do
      case unquote(ast) do
        unquote(bad_var) when is_binary(unquote(bad_var)) ->
          case String.valid?(unquote(bad_var)) do
            true -> unquote(bad_var)
            false -> unquote(bad_ast)
          end
        unquote(bad_var) -> unquote(bad_ast)
      end
    end
    {ast, Context.may_raise(ctx)}
  end


  defp _meta_validate_binary(value, ctx, _opts) when is_binary(value) do
    {value, ctx}
  end

  defp _meta_validate_binary(value, ctx, _opts)
   when is_atom(value) or is_number(value) do
    Error.comptime(ctx, bad_value(value))
  end

  defp _meta_validate_binary(ast, ctx, _opts) do
    {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
    ast = quote do
      case unquote(ast) do
        value when is_binary(value) -> value
        unquote(bad_var) -> unquote(bad_ast)
      end
    end
    {ast, Context.may_raise(ctx)}
  end

end