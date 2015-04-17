defmodule Extract.BasicTypes do

  use Extract.Pipeline

  require Extract.Error

  alias Extract.Error
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


  defmacro types() do
    [:undefined, :atom, :boolean, :integer, :float, :number, :string, :binary]
  end


  defmacro receipts() do
    [{:undefined, :undefined},
     {:undefined, :atom},
     {:undefined, :boolean},
     {:undefined, :integer},
     {:undefined, :float},
     {:undefined, :number},
     {:undefined, :string},
     {:undefined, :binary},
     {:atom, :undefined},
     {:atom, :atom},
     {:atom, :boolean},
     {:atom, :string},
     {:atom, :binary},
     {:boolean, :undefined},
     {:boolean, :atom},
     {:boolean, :boolean},
     {:boolean, :string},
     {:boolean, :binary},
     {:integer, :undefined},
     {:integer, :integer},
     {:integer, :float},
     {:integer, :number},
     {:integer, :string},
     {:integer, :binary},
     {:float, :undefined},
     {:float, :integer},
     {:float, :float},
     {:float, :number},
     {:float, :string},
     {:float, :binary},
     {:number, :undefined},
     {:number, :integer},
     {:number, :float},
     {:number, :number},
     {:number, :string},
     {:number, :binary},
     {:string, :undefined},
     {:string, :atom},
     {:string, :boolean},
     {:string, :integer},
     {:string, :float},
     {:string, :number},
     {:string, :string},
     {:string, :binary},
     {:binary, :undefined},
     {:binary, :atom},
     {:binary, :boolean},
     {:binary, :integer},
     {:binary, :float},
     {:binary, :number},
     {:binary, :string},
     {:binary, :binary}]
  end


  defmacro validate(value, format, opts \\ []) do
    pipeline value, env: __ENV__, caller: __CALLER__ do
      _meta_validate format, opts
      Meta.terminate
    rescue
      Meta.comptime_rescue
    end
  end


  defmacro validate!(value, format, opts \\ []) do
    pipeline value, env: __ENV__, caller: __CALLER__ do
      _meta_validate format, opts
      Meta.terminate!
    rescue
      Meta.comptime_rescue!
    end
  end


  defmacro distill(value, from, to, opts \\ []) do
    pipeline value, env: __ENV__, caller: __CALLER__ do
      _meta_distill from, to, opts
      Meta.terminate
    rescue
      Meta.comptime_rescue
    end
  end


  defmacro distill!(value, from, to, opts \\ []) do
    pipeline value, env: __ENV__, caller: __CALLER__ do
      _meta_distill from, to, opts
      Meta.terminate!
    rescue
      Meta.comptime_rescue!
    end
  end


  def _meta_distill(ast, ctx, from, to, opts) do
    pipeline ast, ctx do
      branch from do
        :undefined ->
          Meta.type_info :undefined, "undefined"
          branch to do
            :undefined ->
              Meta.type_info :undefined, "undefined"
              _meta_validate :undefined, opts
            :atom ->
              Meta.type_info :atom, "atom"
              _meta_validate :atom, opts
            :boolean ->
              Meta.type_info :boolean, "boolean"
              _meta_validate :boolean, opts
            :integer ->
              Meta.type_info :integer, "integer"
              _meta_validate :integer, opts
            :float ->
              Meta.type_info :float, "float"
              _meta_validate :float, opts
            :number ->
              Meta.type_info :number, "number"
              _meta_validate :number, opts
            :string ->
              Meta.type_info :string, "string"
              _meta_validate :string, opts
            :binary ->
              Meta.type_info :binary, "binary"
              _meta_validate :binary, opts
          else
            _meta_bad_receipt_error from, to
          end
        :atom ->
          Meta.type_info :atom, "atom"
          branch to do
            :undefined ->
              Meta.type_info :undefined, "undefined"
              _meta_validate :undefined, opts
            :atom ->
              Meta.type_info :atom, "atom"
              _meta_validate :atom, opts
            :boolean ->
              Meta.type_info :boolean, "boolean"
              _meta_atom_to_bool
              _meta_validate :boolean, opts
            :string ->
              Meta.type_info :string, "string"
              _meta_to_string
              _meta_validate :string, opts
            :binary ->
              Meta.type_info :binary, "binary"
              _meta_to_string
              _meta_validate :binary, opts
          else
            _meta_bad_receipt_error from, to
          end
        :boolean ->
          Meta.type_info :boolean, "boolean"
          branch to do
            :undefined ->
              Meta.type_info :undefined, "undefined"
              _meta_validate :undefined, opts
            :atom ->
              Meta.type_info :atom, "atom"
              _meta_validate :atom, opts
            :boolean ->
              Meta.type_info :boolean, "boolean"
              _meta_validate :boolean, opts
            :string ->
              Meta.type_info :string, "string"
              _meta_to_string
              _meta_validate :string, opts
            :binary ->
              Meta.type_info :binary, "binary"
              _meta_to_string
              _meta_validate :binary, opts
          else
            _meta_bad_receipt_error from, to
          end
        :integer ->
          Meta.type_info :integer, "integer"
          branch to do
            :undefined ->
              Meta.type_info :undefined, "undefined"
              _meta_validate :undefined, opts
            :integer ->
              Meta.type_info :integer, "integer"
              _meta_validate :integer, opts
            :float ->
              Meta.type_info :float, "float"
              _meta_number_to_float
              _meta_validate :float, opts
            :number ->
              Meta.type_info :number, "number"
              _meta_validate :number, opts
            :string ->
              Meta.type_info :string, "string"
              _meta_to_string
              _meta_validate :string, opts
            :binary ->
              Meta.type_info :binary, "binary"
              _meta_to_string
              _meta_validate :binary, opts
          else
            _meta_bad_receipt_error from, to
          end
        :float ->
          Meta.type_info :float, "float"
          branch to do
            :undefined ->
              Meta.type_info :undefined, "undefined"
              _meta_validate :undefined, opts
            :integer ->
              Meta.type_info :integer, "integer"
              _meta_number_to_int
              _meta_validate :integer, opts
            :float ->
              Meta.type_info :float, "float"
              _meta_validate :float, opts
            :number ->
              Meta.type_info :number, "number"
              _meta_validate :number, opts
            :string ->
              Meta.type_info :string, "string"
              _meta_to_string
              _meta_validate :string, opts
            :binary ->
              Meta.type_info :binary, "binary"
              _meta_to_string
              _meta_validate :binary, opts
          else
            _meta_bad_receipt_error from, to
          end
        :number ->
          Meta.type_info :number, "number"
          branch to do
            :undefined ->
              Meta.type_info :undefined, "undefined"
              _meta_validate :undefined, opts
            :integer ->
              Meta.type_info :integer, "integer"
              _meta_number_to_int
              _meta_validate :integer, opts
            :float ->
              Meta.type_info :float, "float"
              _meta_number_to_float
              _meta_validate :float, opts
            :number ->
              Meta.type_info :number, "number"
              _meta_validate :number, opts
            :string ->
              Meta.type_info :string, "string"
              _meta_to_string
              _meta_validate :string, opts
            :binary ->
              Meta.type_info :binary, "binary"
              _meta_to_string
              _meta_validate :binary, opts
          else
            _meta_bad_receipt_error from, to
          end
        :string ->
          Meta.type_info :string, "string"
          branch to do
            :undefined ->
              Meta.type_info :undefined, "undefined"
              _meta_validate :undefined, opts
            :atom ->
              Meta.type_info :atom, "atom"
              _meta_str_to_atom
              _meta_validate :atom, opts
            :boolean ->
              Meta.type_info :boolean, "boolean"
              _meta_str_to_bool
              _meta_validate :boolean, opts
            :integer ->
              Meta.type_info :integer, "integer"
              _meta_str_to_int
              _meta_validate :integer, opts
            :float ->
              Meta.type_info :float, "float"
              _meta_str_to_float
              _meta_validate :float, opts
            :number ->
              Meta.type_info :number, "number"
              _meta_str_to_num
              _meta_validate :number, opts
            :string ->
              Meta.type_info :string, "string"
              Util.identity
              _meta_validate :string, opts
            :binary ->
              Meta.type_info :binary, "binary"
              _meta_validate :binary, opts
          else
            _meta_bad_receipt_error from, to
          end
        :binary ->
          Meta.type_info :binary, "binary"
          branch to do
            :undefined ->
              Meta.type_info :undefined, "undefined"
              _meta_validate :undefined, opts
            :atom ->
              Meta.type_info :atom, "atom"
              _meta_str_to_atom
              _meta_validate :atom, opts
            :boolean ->
              Meta.type_info :boolean, "boolean"
              _meta_str_to_bool
              _meta_validate :boolean, opts
            :integer ->
              Meta.type_info :integer, "integer"
              _meta_str_to_int
              _meta_validate :integer, opts
            :float ->
              Meta.type_info :float, "float"
              _meta_str_to_float
              _meta_validate :float, opts
            :number ->
              Meta.type_info :number, "number"
              _meta_str_to_num
              _meta_validate :number, opts
            :string ->
              Meta.type_info :string, "string"
              _meta_validate :string, opts
            :binary ->
              Meta.type_info :binary, "binary"
              _meta_validate :binary, opts
          else
            _meta_bad_receipt_error from, to
          end
      else
        _meta_bad_receipt_error from, to
      end
    end
  end


  def _meta_validate(ast, ctx, format, opts) do
    pipeline ast, ctx do
      branch format do
        :undefined ->
          Meta.type_info :undefined, "undefined"
          Meta.allowed_options opts, []
          _meta_validate_undefined opts
        :atom ->
          Meta.type_info :atom, "atom"
          Meta.allowed_options opts,
            [:optional, :allow_undefined, :allow_missing, :default, :allowed]
          condition Meta.defined?(opts) do
            _meta_validate_atom opts
            Meta.allowed_value opts
          end
        :boolean ->
          Meta.type_info :boolean, "boolean"
          Meta.allowed_options opts,
            [:optional, :allow_undefined, :allow_missing, :default, :allowed]
          condition Meta.defined?(opts) do
            _meta_validate_boolean opts
            Meta.allowed_value opts
          end
        :integer ->
          Meta.type_info :integer, "integer"
          Meta.allowed_options opts,
            [:optional, :allow_undefined, :allow_missing,
             :default, :allowed, :min, :max]
          condition Meta.defined?(opts) do
            _meta_validate_number opts, :is_integer
            Meta.allowed_value opts
          end
        :float ->
          Meta.type_info :float, "float"
          Meta.allowed_options opts,
            [:optional, :allow_undefined, :allow_missing,
             :default, :allowed, :min, :max]
          condition Meta.defined?(opts) do
            _meta_validate_number opts, :is_float
            Meta.allowed_value opts
          end
        :number ->
          Meta.type_info :number, "number"
          Meta.allowed_options opts,
            [:optional, :allow_undefined, :allow_missing,
             :default, :allowed, :min, :max]
          condition Meta.defined?(opts) do
            _meta_validate_number opts
            Meta.allowed_value opts
          end
        :string ->
          Meta.type_info :string, "string"
          Meta.allowed_options opts,
            [:optional, :allow_undefined, :allow_missing, :default, :allowed]
          condition Meta.defined?(opts) do
            _meta_validate_string opts
            Meta.allowed_value opts
          end
        :binary ->
          Meta.type_info :binary, "binary"
          Meta.allowed_options opts,
            [:optional, :allow_undefined, :allow_missing, :default, :allowed]
          condition Meta.defined?(opts) do
            _meta_validate_binary opts
            Meta.allowed_value opts
          end
      else
        _meta_bad_format_error format
      end
    end
  end



  defp _meta_bad_receipt_error(_ast, ctx, from, to) do
    case is_atom(from) and is_atom(to) do
      true -> Error.comptime(ctx, bad_receipt(from, to))
      false ->
        ast = Error.runtime(ctx, bad_receipt(from, to))
        {ast, Context.may_raise(ctx)}
    end
  end


  defp _meta_bad_format_error(_ast, ctx, format) do
    case is_atom(format) do
      true -> Error.comptime(ctx, bad_format(format))
      false -> {Error.runtime(ctx, bad_format(format)), Context.may_raise(ctx)}
    end
  end


  defp _meta_atom_to_bool(ast, ctx) do
    case ast do
      true -> {true, ctx}
      false -> {false, ctx}
      value when is_atom(value) ->
        Error.comptime(ctx, distillation_error(value))
      value when is_comptime(value) ->
        # Should not really happen, the value should have been validated
        Error.comptime(ctx, error(:internal_error, "internal error"))
      ast ->
        # We assume the value is an integer, it should have been validated
        {error, [var]} = Error.runtime(ctx, distillation_error/1)
        ast = quote do
          case unquote(ast) do
            true -> true
            false -> false
            unquote(var) -> unquote(error)
          end
        end
        {ast, Context.may_raise(ctx)}
    end
  end


  defp _meta_number_to_float(ast, ctx) do
    case ast do
      value when is_float(value) ->
        {value, ctx}
      value when is_integer(value) ->
        {value / 1, ctx}
      value when is_comptime(value) ->
        # Should not really happen, the value should have been validated
        Error.comptime(ctx, error(:internal_error, "internal error"))
      ast ->
        # We assume the value is an integer, it should have been validated
        {quote(do: unquote(ast) / 1), ctx}
    end
  end


  defp _meta_number_to_int(ast, ctx) do
    case ast do
      value when is_integer(value) ->
        {value, ctx}
      value when is_float(value) ->
        {round(value), ctx}
      value when is_comptime(value) ->
        # Should not really happen, the value should have been validated
        Error.comptime(ctx, error(:internal_error, "internal error"))
      ast ->
        # We assume the value is an integer, it should have been validated
        {quote(do: round(unquote(ast))), ctx}
    end
  end


  defp _meta_str_to_atom(ast, ctx) do
    case ast do
      value when is_binary(value) ->
        try do
          {String.to_existing_atom(value), ctx}
        rescue
          ArgumentError ->
            Error.comptime(ctx, value_not_allowed(value))
        end
      value when is_comptime(value) ->
        # Should not really happen, the value should have been validated
        Error.comptime(ctx, error(:internal_error, "internal error"))
      ast ->
        # We assume the value is a string, it should have been validated
        {error, [var]} = Error.runtime(ctx, value_not_allowed/1)
        ast = quote do
          unquote(var) = unquote(ast)
          try do
            String.to_existing_atom(unquote(var))
          rescue
            ArgumentError -> unquote(error)
          end
        end
        {ast, Context.may_raise(ctx)}
    end
  end


  defp _meta_str_to_bool(ast, ctx) do
    case ast do
      "true" -> {true, ctx}
      "false" -> {false, ctx}
      value when is_binary(value) ->
        Error.comptime(ctx, distillation_error(value))
      value when is_comptime(value) ->
        # Should not really happen, the value should have been validated
        Error.comptime(ctx, error(:internal_error, "internal error"))
      ast ->
        # We assume the value is a string, it should have been validated
        {error, [var]} = Error.runtime(ctx, distillation_error/1)
        ast = quote do
          case unquote(ast) do
            "true" -> true
            "false" -> false
            unquote(var) -> unquote(error)
          end
        end
        {ast, Context.may_raise(ctx)}
    end
  end


  defp _meta_str_to_int(ast, ctx) do
    case ast do
      value when is_binary(value) ->
        try do
          {String.to_integer(value), ctx}
        rescue
          ArgumentError ->
            Error.comptime(ctx, distillation_error(value))
        end
      value when is_comptime(value) ->
        # Should not really happen, the value should have been validated
        Error.comptime(ctx, error(:internal_error, "internal error"))
      ast ->
        # We assume the value is a string, it should have been validated
        {error, [var]} = Error.runtime(ctx, distillation_error/1)
        ast = quote do
          unquote(var) = unquote(ast)
          try do
            String.to_integer(unquote(var))
          rescue
            ArgumentError -> unquote(error)
          end
        end
        {ast, Context.may_raise(ctx)}
    end
  end


  defp _meta_str_to_float(ast, ctx) do
    case ast do
      value when is_binary(value) ->
        try do
          {String.to_float(value), ctx}
        rescue
          ArgumentError ->
            Error.comptime(ctx, distillation_error(value))
        end
      value when is_comptime(value) ->
        # Should not really happen, the value should have been validated
        Error.comptime(ctx, error(:internal_error, "internal error"))
      ast ->
        # We assume the value is a string, it should have been validated
        {error, [var]} = Error.runtime(ctx, distillation_error/1)
        ast = quote do
          unquote(var) = unquote(ast)
          try do
            String.to_float(unquote(var))
          rescue
            ArgumentError -> unquote(error)
          end
        end
        {ast, Context.may_raise(ctx)}
    end
  end


  defp _meta_str_to_num(ast, ctx) do
    case ast do
      value when is_binary(value) ->
        try do
          {String.to_integer(value), ctx}
        rescue
          ArgumentError ->
            try do
              {String.to_float(value), ctx}
            rescue
              ArgumentError ->
                Error.comptime(ctx, distillation_error(value))
            end
        end
      value when is_comptime(value) ->
        # Should not really happen, the value should have been validated
        Error.comptime(ctx, error(:internal_error, "internal error"))
      ast ->
        # We assume the value is a string, it should have been validated
        {error, [var]} = Error.runtime(ctx, distillation_error/1)
        ast = quote do
          unquote(var) = unquote(ast)
          try do
            String.to_integer(unquote(var))
          rescue
            ArgumentError ->
              try do
                String.to_float(unquote(var))
              rescue
                ArgumentError -> unquote(error)
              end
          end
        end
        {ast, Context.may_raise(ctx)}
    end
  end


  defp _meta_to_string(ast, ctx) do
    case ast do
      value when is_comptime(value) ->
        {to_string(value), ctx}
      ast ->
        {quote(do: to_string(unquote(ast))), ctx}
    end
  end


  defp _meta_validate_undefined(ast, ctx, _opts) do
    undefined_value = Context.undefined_value(ctx)
    {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
    case ast do
      ^undefined_value -> {undefined_value, ctx}
      {type, _, _} = value when type == :{} or type == :%{} ->
        Error.comptime(ctx, bad_value(value))
      value when is_list(value) ->
        Error.comptime(ctx, bad_value(value))
      value when is_comptime(value) ->
        Error.comptime(ctx, bad_value(value))
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


  defp _meta_validate_atom(ast, ctx, _opts) do
    case ast do
      value when is_atom(value) and value != nil ->
        {value, ctx}
      {type, _, _} = value when type == :{} or type == :%{} ->
        Error.comptime(ctx, bad_value(value))
      value when is_list(value) ->
        Error.comptime(ctx, bad_value(value))
      value when is_comptime(value) ->
        Error.comptime(ctx, bad_value(value))
      ast ->
        {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
        ast = quote do
          case unquote(ast) do
            value when is_atom(value) and value != nil ->
              value
            unquote(bad_var) -> unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
    end
  end


  defp _meta_validate_boolean(ast, ctx, _opts) do
    case ast do
      value when is_boolean(value) -> {value, ctx}
      {type, _, _} = value when type == :{} or type == :%{} ->
        Error.comptime(ctx, bad_value(value))
      value when is_list(value) ->
        Error.comptime(ctx, bad_value(value))
      value when is_comptime(value) ->
        Error.comptime(ctx, bad_value(value))
      ast ->
        {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
        ast = quote do
          case unquote(ast) do
            value when is_boolean(value) -> value
            unquote(bad_var) -> unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
    end
  end


  defp _meta_validate_number(ast, ctx, opts, guard_name \\ :is_number) do
    min_opt = Options.fetch(ctx, opts, :min)
    max_opt = Options.fetch(ctx, opts, :max)
    var = Macro.var(:value, __MODULE__)
    guard = {guard_name, [context: Elixir, import: Kernel], [var]}
    {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
    case {apply(Kernel, guard_name, [ast]), ast, min_opt, max_opt} do
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
      {true, num, {:ok, min}, {:ok, max}}
       when num >= min ->
        Error.comptime(ctx, value_too_big(num, max))
      {true, num, {:ok, min}, {:ok, _max}} ->
        Error.comptime(ctx, value_too_small(num, min))
      {false, {type, _, _} = value, _, _}
       when type == :{} or type == :%{} ->
        Error.comptime(ctx, bad_value(value))
      {false, value, _, _} when is_list(value) ->
        Error.comptime(ctx, bad_value(value))
      {false, value, _, _}
       when is_comptime(value) ->
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
        {small_ast, [small_var]} = Error.runtime(ctx, value_too_small(min)/1)
        ast = quote do
          case unquote(ast) do
            unquote(var) when unquote(guard)
             and unquote(var) >= unquote(min) ->
              unquote(var)
            unquote(small_var) = unquote(var) when unquote(guard) ->
              unquote(small_ast)
            unquote(bad_var) ->
              unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
      {false, ast, :error, {:ok, max}} ->
        {big_ast, [big_var]} = Error.runtime(ctx, value_too_big(max)/1)
        ast = quote do
          case unquote(ast) do
            unquote(var) when unquote(guard)
             and unquote(var) <= unquote(max) ->
              unquote(var)
            unquote(big_var) = unquote(var) when unquote(guard) ->
              unquote(big_ast)
            unquote(bad_var) ->
              unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
      {false, ast, {:ok, min}, {:ok, max}} ->
        {small_ast, [small_var]} = Error.runtime(ctx, value_too_small(min)/1)
        {big_ast, [big_var]} = Error.runtime(ctx, value_too_big(max)/1)
        ast = quote do
          case unquote(ast) do
            unquote(var) when unquote(guard)
             and unquote(var) >= unquote(min)
             and unquote(var) <= unquote(max) ->
              unquote(var)
            unquote(big_var) = unquote(var) when unquote(guard)
             and unquote(big_var) >= unquote(min) ->
              unquote(big_ast)
            unquote(small_var) = unquote(var) when unquote(guard) ->
              unquote(small_ast)
            unquote(bad_var) ->
              unquote(bad_ast)
          end
        end
        {ast, Context.may_raise(ctx)}
    end
  end


  defp _meta_validate_string(ast, ctx, _opts) do
    case ast do
      value when is_binary(value) ->
        case String.valid?(value) do
          false -> Error.comptime(ctx, bad_value(value))
          true -> {value, ctx}
        end
      {type, _, _} = value when type == :{} or type == :%{} ->
        Error.comptime(ctx, bad_value(value))
      value when is_list(value) ->
        Error.comptime(ctx, bad_value(value))
      value when is_comptime(value) ->
        Error.comptime(ctx, bad_value(value))
      ast ->
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
  end


  defp _meta_validate_binary(ast, ctx, _opts) do
    case ast do
      value when is_binary(value) -> {value, ctx}
      {type, _, _} = value when type == :{} or type == :%{} ->
        Error.comptime(ctx, bad_value(value))
      value when is_list(value) ->
        Error.comptime(ctx, bad_value(value))
      value when is_comptime(value) ->
        Error.comptime(ctx, bad_value(value))
      ast ->
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

end