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
    [:undefined,
     :atom,
     :boolean,
     :integer,
     :float,
     :string,
     :binary,
     :list,
     :tuple,
     :map,
     :struct]
  end


  defp _meta_validate(ast, ctx, format, opts) do
    pipeline ast, ctx do
      branch format do
        # :undefined -> _meta_validate_undefined opts
        # :atom      -> _meta_validate_atom opts
        # :boolean   -> _meta_validate_boolean opts
        :integer   ->
          Meta.type_info(:integer, "integer")
          Meta.allowed_options opts,
            [:optional, :allow_undefined, :allow_missing, :default, :allowed, :min, :max]
          condition Meta.defined?(opts) do
            _meta_validate_integer opts
            Meta.allowed_value opts
          end
        # :float     -> _meta_validate_float opts
        # :string    -> _meta_validate_string opts
        # :binary    -> _meta_validate_binary opts
        # :list      -> _meta_validate_list opts
        # :tuple     -> _meta_validate_tuple opts
        # :map       -> _meta_validate_map opts
        # :struct    -> _meta_validate_struct opts
      end
    end
  end


  defp _meta_validate_integer(value, ctx, opts) when is_integer(value) do
    min = Options.fetch(ctx, opts, :min)
    max = Options.fetch(ctx, opts, :max)
    case {value, min, max} do
      {int, :error, :error} -> {int, ctx}
      {int, {:ok, min}, :error} when int >= min -> {int, ctx}
      {int, {:ok, min}, :error} ->
        Error.comptime(ctx, value_too_small(int, min))
      {int, :error, {:ok, max}} when int <= max -> {int, ctx}
      {int, :error, {:ok, max}} ->
        Error.comptime(ctx, value_too_big(int, max))
      {int, {:ok, min}, {:ok, max}} when int >= min and int <= max -> {int, ctx}
      {int, {:ok, min}, {:ok, max}} when int >= min-> {int, ctx}
        Error.comptime(ctx, value_too_big(int. max))
      {int, {:ok, min}, {:ok, _max}} ->
        Error.comptime(ctx, value_too_small(int. min))
    end
  end

  defp _meta_validate_integer(value, ctx, _opts)
   when is_atom(value) or is_number(value) or is_binary(value) do
    Error.comptime(ctx, bad_value(value))
  end

  defp _meta_validate_integer(ast, ctx, opts) do
    min = Options.fetch(ctx, opts, :min)
    max = Options.fetch(ctx, opts, :max)
    case {min, max} do
      {:error, :error} ->
        {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
        ast = quote do
          case unquote(ast) do
            value when is_integer(value) -> value
            unquote(bad_var) -> unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
      {{:ok, min}, :error} ->
        {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
        {small_ast, [small_var]} = Error.runtime(ctx, value_too_small(min)/1)
        ast = quote do
          case unquote(ast) do
            value when is_integer(value) and value >= unquote(min) -> value
            unquote(small_var) when is_integer(unquote(small_var)) ->
              unquote(small_ast)
            unquote(bad_var) -> unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
      {:error, {:ok, max}} ->
        {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
        {big_ast, [big_var]} = Error.runtime(ctx, value_too_big(max)/1)
        ast = quote do
          case unquote(ast) do
            value when is_integer(value) and value <= unquote(max) -> value
            unquote(big_var) when is_integer(unquote(big_var)) ->
              unquote(big_ast)
            unquote(bad_var) -> unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
      {{:ok, min}, {:ok, max}} ->
        {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
        {big_ast, [big_var]} = Error.runtime(ctx, value_too_big(max)/1)
        {small_ast, [small_var]} = Error.runtime(ctx, value_too_small(min)/1)
        ast = quote do
          case unquote(ast) do
            value when is_integer(value)
             and value >= unquote(min) and value <= unquote(max) -> value
            unquote(big_var) when is_integer(unquote(big_var))
             and unquote(big_var) >= unquote(min) ->
              unquote(big_ast)
            unquote(small_var) when is_integer(unquote(small_var)) ->
              unquote(small_ast)
            unquote(bad_var) -> unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
    end
  end

end