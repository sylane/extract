defmodule Extract.BasicTypes do

  use Extract

  alias Extract.Meta
  alias Extract.Meta.Error
  alias Extract.Meta.Context
  alias Extract.Meta.Options


  # extract_statment :undefined, "undefined" do
  #   unquote(match_undefined) = value -> value
  #   value -> raise Error.bad_value(value)
  # end


  Extract.register_extract(:undefined, "undefined", :_extract_undefined)
  defp _extract_undefined(ast, ctx, opts, body) do
    pipeline ast, ctx do
      Meta.type_info :undefined, "undefined"
      Meta.allowed_options opts, []
      Meta.assert_undefined_body body
      condition Meta.comptime? do
        _extract_undefined_comptime opts
      else
        _extract_undefined_runtime opts
      end
    end
  end


  defp _extract_undefined_comptime(ast, ctx, _opts) do
    undefined_value = Context.undefined_value(ctx)
    new_ast = case ast do
      ^undefined_value = value -> value
      value -> Error.comptime(ctx, bad_value(value))
    end
    {new_ast, ctx}
  end


  defp _extract_undefined_runtime(ast, ctx, _opts) do
    undefined_value = Context.undefined_value(ctx)
    {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
    new_ast = quote do
      case unquote(ast) do
        unquote(undefined_value) = value -> value
        unquote(bad_var) -> unquote(bad_ast)
      end
    end
    {new_ast, Context.may_raise(ctx)}
  end


  # extract_statment :atom, "atom", [:optional, :default, :allowed] do
  #   value when is_atom(value) and value != nil -> value
  #   value -> raise Error.bad_value(value)
  # end


  Extract.register_extract(:atom, "atom", :_extract_atom)
  defp _extract_atom(ast, ctx, opts, body) do
    pipeline ast, ctx do
      Meta.type_info :atom, "atom"
      Meta.allowed_options opts, [:optional, :default, :allowed]
      Meta.assert_undefined_body body
      condition Meta.defined?(opts) do
        condition Meta.comptime? do
          _extract_atom_comptime opts
        else
          _extract_atom_runtime opts
        end
        Meta.allowed_value opts
      end
    end
  end


  defp _extract_atom_comptime(ast, ctx, _opts) do
    new_ast = case ast do
      value when is_atom(value) and value != nil -> value
      value -> Error.comptime(ctx, bad_value(value))
    end
    {new_ast, ctx}
  end


  defp _extract_atom_runtime(ast, ctx, _opts) do
    {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
    new_ast = quote do
      case unquote(ast) do
        value when is_atom(value) and value != nil ->
          value
        unquote(bad_var) -> unquote(bad_ast)
      end
    end
    {new_ast, Context.may_raise(ctx)}
  end


  # extract_statment :boolean, "boolean", [:optional, :default, :allowed] do
  #   value when is_boolean(value) -> value
  #   value -> raise Error.bad_value(value)
  # end


  Extract.register_extract(:boolean, "boolean", :_extract_boolean)
  defp _extract_boolean(ast, ctx, opts, body) do
    pipeline ast, ctx do
      Meta.type_info :boolean, "boolean"
      Meta.allowed_options opts, [:optional, :default, :allowed]
      Meta.assert_undefined_body body
      condition Meta.defined?(opts) do
        condition Meta.comptime? do
          _extract_boolean_comptime opts
        else
          _extract_boolean_runtime opts
        end
        Meta.allowed_value opts
      end
    end
  end


  defp _extract_boolean_comptime(ast, ctx, _opts) do
    new_ast = case ast do
      value when is_boolean(value) -> value
      value -> Error.comptime(ctx, bad_value(value))
    end
    {new_ast, ctx}
  end


  defp _extract_boolean_runtime(ast, ctx, _opts) do
    {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
    new_ast = quote do
      case unquote(ast) do
        value when is_boolean(value) -> value
        unquote(bad_var) -> unquote(bad_ast)
      end
    end
    {new_ast, Context.may_raise(ctx)}
  end


  # extract_custom :integer, "integer",
  #                [:optional, :default, :allowed, :min, :max],
  #                _extract_number_comptime(&is_integer/1),
  #                _extract_number_runtime(:is_integer)


  Extract.register_extract(:integer, "integer", :_extract_integer)
  defp _extract_integer(ast, ctx, opts, body) do
    pipeline ast, ctx do
      Meta.type_info :integer, "integer"
      Meta.allowed_options opts, [:optional, :default, :allowed, :min, :max]
      Meta.assert_undefined_body body
      condition Meta.defined?(opts) do
        condition Meta.comptime? do
          _extract_number_comptime opts, &is_integer/1
        else
          _extract_number_runtime opts, :is_integer
        end
        Meta.allowed_value opts
      end
    end
  end


  # extract_custom :float, "float",
  #                [:optional, :default, :allowed, :min, :max],
  #                _extract_number_comptime(&is_float/1),
  #                _extract_number_runtime(:is_float)


  Extract.register_extract(:float, "float", :_extract_float)
  defp _extract_float(ast, ctx, opts, body) do
    pipeline ast, ctx do
      Meta.type_info :float, "float"
      Meta.allowed_options opts, [:optional, :default, :allowed, :min, :max]
      Meta.assert_undefined_body body
      condition Meta.defined?(opts) do
        condition Meta.comptime? do
          _extract_number_comptime opts, &is_float/1
        else
          _extract_number_runtime opts, :is_float
        end
        Meta.allowed_value opts
      end
    end
  end


  # extract_custom :number, "number",
  #                [:optional, :default, :allowed, :min, :max],
  #                _extract_number_comptime(&is_number/1),
  #                _extract_number_runtime(:is_number)


  Extract.register_extract(:number, "number", :_extract_number)
  defp _extract_number(ast, ctx, opts, body) do
    pipeline ast, ctx do
      Meta.type_info :number, "number"
      Meta.allowed_options opts, [:optional, :default, :allowed, :min, :max]
      Meta.assert_undefined_body body
      condition Meta.defined?(opts) do
        condition Meta.comptime? do
          _extract_number_comptime opts, &is_number/1
        else
          _extract_number_runtime opts, :is_number
        end
        Meta.allowed_value opts
      end
    end
  end


  # extract_statment :string, "string", [:optional, :default, :allowed] do
  #   value when is_binary(value) ->
  #     case String.valid?(value) do
  #       true -> value
  #       false -> raise Error.bad_value(value)
  #     end
  #   value -> raise Error.bad_value(value)
  # end


  Extract.register_extract(:string, "string", :_extract_string)
  defp _extract_string(ast, ctx, opts, body) do
    pipeline ast, ctx do
      Meta.type_info :string, "string"
      Meta.allowed_options opts, [:optional, :default, :allowed]
      Meta.assert_undefined_body body
      condition Meta.defined?(opts) do
        condition Meta.comptime? do
          _extract_string_comptime opts
        else
          _extract_string_runtime opts
        end
        Meta.allowed_value opts
      end
    end
  end


  defp _extract_string_comptime(ast, ctx, _opts) do
    new_ast = case ast do
      value when is_binary(value) ->
        case String.valid?(value) do
          true -> value
          false -> Error.comptime(ctx, bad_value(value))
        end
      value -> Error.comptime(ctx, bad_value(value))
    end
    {new_ast, ctx}
  end


  defp _extract_string_runtime(ast, ctx, _opts) do
    {error_ast, [error_var]} = Error.runtime(ctx, bad_value/1)
    new_ast = quote do
      case unquote(ast) do
        value = unquote(error_var) when is_binary(value) ->
          case String.valid?(value) do
            true -> value
            false -> unquote(error_ast)
          end
        unquote(error_var) -> unquote(error_ast)
      end
    end
    {new_ast, Context.may_raise(ctx)}
  end


  # extract_statment :binary, "binary", [:optional, :default, :allowed] do
  #   value when is_binary(value) -> value
  #   value -> raise Error.bad_value(value)
  # end


  Extract.register_extract(:binary, "binary", :_extract_binary)
  defp _extract_binary(ast, ctx, opts, body) do
    pipeline ast, ctx do
      Meta.type_info :binary, "binary"
      Meta.allowed_options opts, [:optional, :default, :allowed]
      Meta.assert_undefined_body body
      condition Meta.defined?(opts) do
        condition Meta.comptime? do
          _extract_binary_comptime opts
        else
          _extract_binary_runtime opts
        end
        Meta.allowed_value opts
      end
    end
  end


  defp _extract_binary_comptime(ast, ctx, _opts) do
    new_ast = case ast do
      value when is_binary(value) -> value
      value -> Error.comptime(ctx, bad_value(value))
    end
    {new_ast, ctx}
  end


  defp _extract_binary_runtime(ast, ctx, _opts) do
    {error_ast, [error_var]} = Error.runtime(ctx, bad_value/1)
    new_ast = quote do
      case unquote(ast) do
        value when is_binary(value) -> value
        unquote(error_var) -> unquote(error_ast)
      end
    end
    {new_ast, Context.may_raise(ctx)}
  end


  # receipt_statment :float, :integer, "float to integer" do
  #   value when is_float(value) -> round(value)
  #   value -> raise Error.bad_value(value)
  # end


  Extract.register_receipt({:float, :integer}, "float to integer",
                           :_receipt_float_to_integer)
  defp _receipt_float_to_integer(ast, ctx, opts, body) do
    pipeline ast, ctx do
      Meta.type_info :integer, "integer"
      condition Meta.comptime? do
         _receipt_float_to_integer_comptime opts
       else
         _receipt_float_to_integer_runtime opts
      end
      Extract.validate! :integer, opts, body
    end
  end


  defp _receipt_float_to_integer_comptime(ast, ctx, _opts) do
    new_ast = case ast do
      value when is_float(value) -> round(value)
      value -> Error.comptime(ctx, distillation_error(value))
    end
    {new_ast, ctx}
  end


  defp _receipt_float_to_integer_runtime(ast, ctx, _opts) do
    {error_ast, [error_var]} = Error.runtime(ctx, distillation_error/1)
    new_ast = quote do
      case unquote(ast) do
        value when is_float(value) -> round(value)
        unquote(error_var) -> unquote(error_ast)
      end
    end
    {new_ast, Context.may_raise(ctx)}
  end


  # defp _meta_number_to_int(ast, ctx) do
  #   case ast do
  #     value when is_integer(value) ->
  #       {value, ctx}
  #     value when is_float(value) ->
  #       {round(value), ctx}
  #     value when is_comptime(value) ->
  #       # Should not really happen, the value should have been validated
  #       Error.comptime(ctx, error(:internal_error, "internal error"))
  #     ast ->
  #       # We assume the value is an integer, it should have been validated
  #       {quote(do: round(unquote(ast))), ctx}
  #   end
  # end



  defp _extract_number_comptime(ast, ctx, opts, type_checker) do
    min_opt = Options.fetch(ctx, opts, :min)
    max_opt = Options.fetch(ctx, opts, :max)
    new_ast = case {min_opt, max_opt} do
      {:error, :error} ->
        case {type_checker.(ast), ast} do
          {true, value} -> value
          {false, value }-> Error.comptime(ctx, bad_value(value))
        end
      {{:ok, min}, :error} ->
        case {type_checker.(ast), ast} do
          {true, value} when value >= min -> value
          {true, value} -> Error.comptime(ctx, value_too_small(value, min))
          {false, value} -> Error.comptime(ctx, bad_value(value))
        end
      {:error, {:ok, max}} ->
        case {type_checker.(ast), ast} do
          {true, value} when value <= max -> value
          {true, value} -> Error.comptime(ctx, value_too_big(value, max))
          {false, value} -> Error.comptime(ctx, bad_value(value))
        end
      {{:ok, min}, {:ok, max}} ->
        case {type_checker.(ast), ast} do
          {true, value} when value >= min and value <= max -> value
          {true, value} when value >= min ->
            Error.comptime(ctx, value_too_big(value, max))
          {true, value} -> Error.comptime(ctx, value_too_small(value, min))
          {false, value} -> Error.comptime(ctx, bad_value(value))
        end
    end
    {new_ast, ctx}
  end


  defp _extract_number_runtime(ast, ctx, opts, guard_name) do
    min_opt = Options.fetch(ctx, opts, :min)
    max_opt = Options.fetch(ctx, opts, :max)
    var = Macro.var(:value, __MODULE__)
    guard = {guard_name, [context: Elixir, import: Kernel], [var]}
    {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
    new_ast = case {min_opt, max_opt} do
      {:error, :error} ->
        quote do
          case unquote(ast) do
            unquote(var) when unquote(guard) -> unquote(var)
            unquote(bad_var) -> unquote(bad_ast)
          end
        end
      {{:ok, min}, :error} ->
        {error_ast, [error_var]} = Error.runtime(ctx, value_too_small(min)/1)
        quote do
          case unquote(ast) do
            unquote(var) when unquote(guard) and unquote(var) >= unquote(min) ->
              unquote(var)
            unquote(var) = unquote(error_var) when unquote(guard) ->
              unquote(error_ast)
            unquote(bad_var) -> unquote(bad_ast)
          end
        end
      {:error, {:ok, max}} ->
        {error_ast, [error_var]} = Error.runtime(ctx, value_too_big(max)/1)
        quote do
          case unquote(ast) do
            unquote(var) when unquote(guard) and unquote(var) <= unquote(max) ->
              unquote(var)
            unquote(var) = unquote(error_var) when unquote(guard) ->
              unquote(error_ast)
            unquote(bad_var) -> unquote(bad_ast)
          end
        end
      {{:ok, min}, {:ok, max}} ->
        {small_error, [small_var]} = Error.runtime(ctx, value_too_small(min)/1)
        {big_error, [big_var]} = Error.runtime(ctx, value_too_big(max)/1)
        quote do
          case unquote(ast) do
            unquote(var) when unquote(guard)
             and unquote(var) >= unquote(min)
             and unquote(var) <= unquote(max) ->
              unquote(var)
            unquote(var) = unquote(big_var) when unquote(guard)
             and unquote(var) >= unquote(min) ->
              unquote(big_error)
            unquote(var) = unquote(small_var) when unquote(guard) ->
              unquote(small_error)
            unquote(bad_var) -> unquote(bad_ast)
          end
        end
    end
    {new_ast, Context.may_raise(ctx)}
  end





  # use Extract.Pipeline

  # require Extract.Error

  # alias Extract.Error
  # alias Extract.Meta
  # alias Extract.Meta.Error
  # alias Extract.Meta.Options
  # alias Extract.Meta.Context
  # alias Extract.Util


  # defmacro __using__(_args) do
  #   quote do
  #     require Extract.Meta
  #     require Extract.Meta.Error
  #     require Extract.Meta.Options
  #     require Extract.Util
  #     require Extract.Valid
  #     require Extract.Trans
  #   end
  # end


  # defmacro types() do
  #   [:undefined, :atom, :boolean, :integer, :float, :number, :string, :binary]
  # end


  # defmacro receipts() do
  #   [{:undefined, :undefined},
  #    {:undefined, :atom},
  #    {:undefined, :boolean},
  #    {:undefined, :integer},
  #    {:undefined, :float},
  #    {:undefined, :number},
  #    {:undefined, :string},
  #    {:undefined, :binary},
  #    {:atom, :undefined},
  #    {:atom, :atom},
  #    {:atom, :boolean},
  #    {:atom, :string},
  #    {:atom, :binary},
  #    {:boolean, :undefined},
  #    {:boolean, :atom},
  #    {:boolean, :boolean},
  #    {:boolean, :string},
  #    {:boolean, :binary},
  #    {:integer, :undefined},
  #    {:integer, :integer},
  #    {:integer, :float},
  #    {:integer, :number},
  #    {:integer, :string},
  #    {:integer, :binary},
  #    {:float, :undefined},
  #    {:float, :integer},
  #    {:float, :float},
  #    {:float, :number},
  #    {:float, :string},
  #    {:float, :binary},
  #    {:number, :undefined},
  #    {:number, :integer},
  #    {:number, :float},
  #    {:number, :number},
  #    {:number, :string},
  #    {:number, :binary},
  #    {:string, :undefined},
  #    {:string, :atom},
  #    {:string, :boolean},
  #    {:string, :integer},
  #    {:string, :float},
  #    {:string, :number},
  #    {:string, :string},
  #    {:string, :binary},
  #    {:binary, :undefined},
  #    {:binary, :atom},
  #    {:binary, :boolean},
  #    {:binary, :integer},
  #    {:binary, :float},
  #    {:binary, :number},
  #    {:binary, :string},
  #    {:binary, :binary}]
  # end


  # defmacro validate(value, format, opts \\ []) do
  #   pipeline value, env: __ENV__, caller: __CALLER__ do
  #     _meta_validate format, opts
  #     Meta.terminate
  #   rescue
  #     Meta.comptime_rescue
  #   end
  # end


  # defmacro validate!(value, format, opts \\ []) do
  #   pipeline value, env: __ENV__, caller: __CALLER__ do
  #     _meta_validate format, opts
  #     Meta.terminate!
  #   rescue
  #     Meta.comptime_rescue!
  #   end
  # end


  # defmacro distill(value, from, to, opts \\ []) do
  #   pipeline value, env: __ENV__, caller: __CALLER__ do
  #     _meta_distill from, to, opts
  #     Meta.terminate
  #   rescue
  #     Meta.comptime_rescue
  #   end
  # end


  # defmacro distill!(value, from, to, opts \\ []) do
  #   pipeline value, env: __ENV__, caller: __CALLER__ do
  #     _meta_distill from, to, opts
  #     Meta.terminate!
  #   rescue
  #     Meta.comptime_rescue!
  #   end
  # end


  # def _meta_distill(ast, ctx, from, to, opts) do
  #   pipeline ast, ctx do
  #     branch from do
  #       :undefined ->
  #         Meta.type_info :undefined, "undefined"
  #         branch to do
  #           :undefined ->
  #             Meta.type_info :undefined, "undefined"
  #             _meta_validate :undefined, opts
  #           :atom ->
  #             Meta.type_info :atom, "atom"
  #             _meta_validate :atom, opts
  #           :boolean ->
  #             Meta.type_info :boolean, "boolean"
  #             _meta_validate :boolean, opts
  #           :integer ->
  #             Meta.type_info :integer, "integer"
  #             _meta_validate :integer, opts
  #           :float ->
  #             Meta.type_info :float, "float"
  #             _meta_validate :float, opts
  #           :number ->
  #             Meta.type_info :number, "number"
  #             _meta_validate :number, opts
  #           :string ->
  #             Meta.type_info :string, "string"
  #             _meta_validate :string, opts
  #           :binary ->
  #             Meta.type_info :binary, "binary"
  #             _meta_validate :binary, opts
  #         else
  #           _meta_bad_receipt_error from, to
  #         end
  #       :atom ->
  #         Meta.type_info :atom, "atom"
  #         branch to do
  #           :undefined ->
  #             Meta.type_info :undefined, "undefined"
  #             _meta_validate :undefined, opts
  #           :atom ->
  #             Meta.type_info :atom, "atom"
  #             _meta_validate :atom, opts
  #           :boolean ->
  #             Meta.type_info :boolean, "boolean"
  #             _meta_atom_to_bool
  #             _meta_validate :boolean, opts
  #           :string ->
  #             Meta.type_info :string, "string"
  #             _meta_to_string
  #             _meta_validate :string, opts
  #           :binary ->
  #             Meta.type_info :binary, "binary"
  #             _meta_to_string
  #             _meta_validate :binary, opts
  #         else
  #           _meta_bad_receipt_error from, to
  #         end
  #       :boolean ->
  #         Meta.type_info :boolean, "boolean"
  #         branch to do
  #           :undefined ->
  #             Meta.type_info :undefined, "undefined"
  #             _meta_validate :undefined, opts
  #           :atom ->
  #             Meta.type_info :atom, "atom"
  #             _meta_validate :atom, opts
  #           :boolean ->
  #             Meta.type_info :boolean, "boolean"
  #             _meta_validate :boolean, opts
  #           :string ->
  #             Meta.type_info :string, "string"
  #             _meta_to_string
  #             _meta_validate :string, opts
  #           :binary ->
  #             Meta.type_info :binary, "binary"
  #             _meta_to_string
  #             _meta_validate :binary, opts
  #         else
  #           _meta_bad_receipt_error from, to
  #         end
  #       :integer ->
  #         Meta.type_info :integer, "integer"
  #         branch to do
  #           :undefined ->
  #             Meta.type_info :undefined, "undefined"
  #             _meta_validate :undefined, opts
  #           :integer ->
  #             Meta.type_info :integer, "integer"
  #             _meta_validate :integer, opts
  #           :float ->
  #             Meta.type_info :float, "float"
  #             _meta_number_to_float
  #             _meta_validate :float, opts
  #           :number ->
  #             Meta.type_info :number, "number"
  #             _meta_validate :number, opts
  #           :string ->
  #             Meta.type_info :string, "string"
  #             _meta_to_string
  #             _meta_validate :string, opts
  #           :binary ->
  #             Meta.type_info :binary, "binary"
  #             _meta_to_string
  #             _meta_validate :binary, opts
  #         else
  #           _meta_bad_receipt_error from, to
  #         end
  #       :float ->
  #         Meta.type_info :float, "float"
  #         branch to do
  #           :undefined ->
  #             Meta.type_info :undefined, "undefined"
  #             _meta_validate :undefined, opts
  #           :integer ->
  #             Meta.type_info :integer, "integer"
  #             _meta_number_to_int
  #             _meta_validate :integer, opts
  #           :float ->
  #             Meta.type_info :float, "float"
  #             _meta_validate :float, opts
  #           :number ->
  #             Meta.type_info :number, "number"
  #             _meta_validate :number, opts
  #           :string ->
  #             Meta.type_info :string, "string"
  #             _meta_to_string
  #             _meta_validate :string, opts
  #           :binary ->
  #             Meta.type_info :binary, "binary"
  #             _meta_to_string
  #             _meta_validate :binary, opts
  #         else
  #           _meta_bad_receipt_error from, to
  #         end
  #       :number ->
  #         Meta.type_info :number, "number"
  #         branch to do
  #           :undefined ->
  #             Meta.type_info :undefined, "undefined"
  #             _meta_validate :undefined, opts
  #           :integer ->
  #             Meta.type_info :integer, "integer"
  #             _meta_number_to_int
  #             _meta_validate :integer, opts
  #           :float ->
  #             Meta.type_info :float, "float"
  #             _meta_number_to_float
  #             _meta_validate :float, opts
  #           :number ->
  #             Meta.type_info :number, "number"
  #             _meta_validate :number, opts
  #           :string ->
  #             Meta.type_info :string, "string"
  #             _meta_to_string
  #             _meta_validate :string, opts
  #           :binary ->
  #             Meta.type_info :binary, "binary"
  #             _meta_to_string
  #             _meta_validate :binary, opts
  #         else
  #           _meta_bad_receipt_error from, to
  #         end
  #       :string ->
  #         Meta.type_info :string, "string"
  #         branch to do
  #           :undefined ->
  #             Meta.type_info :undefined, "undefined"
  #             _meta_validate :undefined, opts
  #           :atom ->
  #             Meta.type_info :atom, "atom"
  #             _meta_str_to_atom
  #             _meta_validate :atom, opts
  #           :boolean ->
  #             Meta.type_info :boolean, "boolean"
  #             _meta_str_to_bool
  #             _meta_validate :boolean, opts
  #           :integer ->
  #             Meta.type_info :integer, "integer"
  #             _meta_str_to_int
  #             _meta_validate :integer, opts
  #           :float ->
  #             Meta.type_info :float, "float"
  #             _meta_str_to_float
  #             _meta_validate :float, opts
  #           :number ->
  #             Meta.type_info :number, "number"
  #             _meta_str_to_num
  #             _meta_validate :number, opts
  #           :string ->
  #             Meta.type_info :string, "string"
  #             Util.identity
  #             _meta_validate :string, opts
  #           :binary ->
  #             Meta.type_info :binary, "binary"
  #             _meta_validate :binary, opts
  #         else
  #           _meta_bad_receipt_error from, to
  #         end
  #       :binary ->
  #         Meta.type_info :binary, "binary"
  #         branch to do
  #           :undefined ->
  #             Meta.type_info :undefined, "undefined"
  #             _meta_validate :undefined, opts
  #           :atom ->
  #             Meta.type_info :atom, "atom"
  #             _meta_str_to_atom
  #             _meta_validate :atom, opts
  #           :boolean ->
  #             Meta.type_info :boolean, "boolean"
  #             _meta_str_to_bool
  #             _meta_validate :boolean, opts
  #           :integer ->
  #             Meta.type_info :integer, "integer"
  #             _meta_str_to_int
  #             _meta_validate :integer, opts
  #           :float ->
  #             Meta.type_info :float, "float"
  #             _meta_str_to_float
  #             _meta_validate :float, opts
  #           :number ->
  #             Meta.type_info :number, "number"
  #             _meta_str_to_num
  #             _meta_validate :number, opts
  #           :string ->
  #             Meta.type_info :string, "string"
  #             _meta_validate :string, opts
  #           :binary ->
  #             Meta.type_info :binary, "binary"
  #             _meta_validate :binary, opts
  #         else
  #           _meta_bad_receipt_error from, to
  #         end
  #     else
  #       _meta_bad_receipt_error from, to
  #     end
  #   end
  # end


  # def _meta_validate(ast, ctx, format, opts) do
  #   pipeline ast, ctx do
  #     branch format do
  #       :undefined ->
  #         Meta.type_info :undefined, "undefined"
  #         Meta.allowed_options opts, []
  #         _meta_validate_undefined opts
  #       :atom ->
  #         Meta.type_info :atom, "atom"
  #         Meta.allowed_options opts,
  #           [:optional, :allow_undefined, :allow_missing, :default, :allowed]
  #         condition Meta.defined?(opts) do
  #           _meta_validate_atom opts
  #           Meta.allowed_value opts
  #         end
  #       :boolean ->
  #         Meta.type_info :boolean, "boolean"
  #         Meta.allowed_options opts,
  #           [:optional, :allow_undefined, :allow_missing, :default, :allowed]
  #         condition Meta.defined?(opts) do
  #           _meta_validate_boolean opts
  #           Meta.allowed_value opts
  #         end
  #       :integer ->
  #         Meta.type_info :integer, "integer"
  #         Meta.allowed_options opts,
  #           [:optional, :allow_undefined, :allow_missing,
  #            :default, :allowed, :min, :max]
  #         condition Meta.defined?(opts) do
  #           _meta_validate_number opts, :is_integer
  #           Meta.allowed_value opts
  #         end
  #       :float ->
  #         Meta.type_info :float, "float"
  #         Meta.allowed_options opts,
  #           [:optional, :allow_undefined, :allow_missing,
  #            :default, :allowed, :min, :max]
  #         condition Meta.defined?(opts) do
  #           _meta_validate_number opts, :is_float
  #           Meta.allowed_value opts
  #         end
  #       :number ->
  #         Meta.type_info :number, "number"
  #         Meta.allowed_options opts,
  #           [:optional, :allow_undefined, :allow_missing,
  #            :default, :allowed, :min, :max]
  #         condition Meta.defined?(opts) do
  #           _meta_validate_number opts
  #           Meta.allowed_value opts
  #         end
  #       :string ->
  #         Meta.type_info :string, "string"
  #         Meta.allowed_options opts,
  #           [:optional, :allow_undefined, :allow_missing, :default, :allowed]
  #         condition Meta.defined?(opts) do
  #           _meta_validate_string opts
  #           Meta.allowed_value opts
  #         end
  #       :binary ->
  #         Meta.type_info :binary, "binary"
  #         Meta.allowed_options opts,
  #           [:optional, :allow_undefined, :allow_missing, :default, :allowed]
  #         condition Meta.defined?(opts) do
  #           _meta_validate_binary opts
  #           Meta.allowed_value opts
  #         end
  #     else
  #       _meta_bad_format_error format
  #     end
  #   end
  # end



  # defp _meta_bad_receipt_error(_ast, ctx, from, to) do
  #   case is_atom(from) and is_atom(to) do
  #     true -> Error.comptime(ctx, bad_receipt(from, to))
  #     false ->
  #       ast = Error.runtime(ctx, bad_receipt(from, to))
  #       {ast, Context.may_raise(ctx)}
  #   end
  # end


  # defp _meta_bad_format_error(_ast, ctx, format) do
  #   case is_atom(format) do
  #     true -> Error.comptime(ctx, bad_format(format))
  #     false -> {Error.runtime(ctx, bad_format(format)), Context.may_raise(ctx)}
  #   end
  # end


  # defp _meta_atom_to_bool(ast, ctx) do
  #   case ast do
  #     true -> {true, ctx}
  #     false -> {false, ctx}
  #     value when is_atom(value) ->
  #       Error.comptime(ctx, distillation_error(value))
  #     value when is_comptime(value) ->
  #       # Should not really happen, the value should have been validated
  #       Error.comptime(ctx, error(:internal_error, "internal error"))
  #     ast ->
  #       # We assume the value is an integer, it should have been validated
  #       {error, [var]} = Error.runtime(ctx, distillation_error/1)
  #       ast = quote do
  #         case unquote(ast) do
  #           true -> true
  #           false -> false
  #           unquote(var) -> unquote(error)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #   end
  # end


  # defp _meta_number_to_float(ast, ctx) do
  #   case ast do
  #     value when is_float(value) ->
  #       {value, ctx}
  #     value when is_integer(value) ->
  #       {value / 1, ctx}
  #     value when is_comptime(value) ->
  #       # Should not really happen, the value should have been validated
  #       Error.comptime(ctx, error(:internal_error, "internal error"))
  #     ast ->
  #       # We assume the value is an integer, it should have been validated
  #       {quote(do: unquote(ast) / 1), ctx}
  #   end
  # end


  # defp _meta_number_to_int(ast, ctx) do
  #   case ast do
  #     value when is_integer(value) ->
  #       {value, ctx}
  #     value when is_float(value) ->
  #       {round(value), ctx}
  #     value when is_comptime(value) ->
  #       # Should not really happen, the value should have been validated
  #       Error.comptime(ctx, error(:internal_error, "internal error"))
  #     ast ->
  #       # We assume the value is an integer, it should have been validated
  #       {quote(do: round(unquote(ast))), ctx}
  #   end
  # end


  # defp _meta_str_to_atom(ast, ctx) do
  #   case ast do
  #     value when is_binary(value) ->
  #       try do
  #         {String.to_existing_atom(value), ctx}
  #       rescue
  #         ArgumentError ->
  #           Error.comptime(ctx, value_not_allowed(value))
  #       end
  #     value when is_comptime(value) ->
  #       # Should not really happen, the value should have been validated
  #       Error.comptime(ctx, error(:internal_error, "internal error"))
  #     ast ->
  #       # We assume the value is a string, it should have been validated
  #       {error, [var]} = Error.runtime(ctx, value_not_allowed/1)
  #       ast = quote do
  #         unquote(var) = unquote(ast)
  #         try do
  #           String.to_existing_atom(unquote(var))
  #         rescue
  #           ArgumentError -> unquote(error)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #   end
  # end


  # defp _meta_str_to_bool(ast, ctx) do
  #   case ast do
  #     "true" -> {true, ctx}
  #     "false" -> {false, ctx}
  #     value when is_binary(value) ->
  #       Error.comptime(ctx, distillation_error(value))
  #     value when is_comptime(value) ->
  #       # Should not really happen, the value should have been validated
  #       Error.comptime(ctx, error(:internal_error, "internal error"))
  #     ast ->
  #       # We assume the value is a string, it should have been validated
  #       {error, [var]} = Error.runtime(ctx, distillation_error/1)
  #       ast = quote do
  #         case unquote(ast) do
  #           "true" -> true
  #           "false" -> false
  #           unquote(var) -> unquote(error)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #   end
  # end


  # defp _meta_str_to_int(ast, ctx) do
  #   case ast do
  #     value when is_binary(value) ->
  #       try do
  #         {String.to_integer(value), ctx}
  #       rescue
  #         ArgumentError ->
  #           Error.comptime(ctx, distillation_error(value))
  #       end
  #     value when is_comptime(value) ->
  #       # Should not really happen, the value should have been validated
  #       Error.comptime(ctx, error(:internal_error, "internal error"))
  #     ast ->
  #       # We assume the value is a string, it should have been validated
  #       {error, [var]} = Error.runtime(ctx, distillation_error/1)
  #       ast = quote do
  #         unquote(var) = unquote(ast)
  #         try do
  #           String.to_integer(unquote(var))
  #         rescue
  #           ArgumentError -> unquote(error)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #   end
  # end


  # defp _meta_str_to_float(ast, ctx) do
  #   case ast do
  #     value when is_binary(value) ->
  #       try do
  #         {String.to_float(value), ctx}
  #       rescue
  #         ArgumentError ->
  #           Error.comptime(ctx, distillation_error(value))
  #       end
  #     value when is_comptime(value) ->
  #       # Should not really happen, the value should have been validated
  #       Error.comptime(ctx, error(:internal_error, "internal error"))
  #     ast ->
  #       # We assume the value is a string, it should have been validated
  #       {error, [var]} = Error.runtime(ctx, distillation_error/1)
  #       ast = quote do
  #         unquote(var) = unquote(ast)
  #         try do
  #           String.to_float(unquote(var))
  #         rescue
  #           ArgumentError -> unquote(error)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #   end
  # end


  # defp _meta_str_to_num(ast, ctx) do
  #   case ast do
  #     value when is_binary(value) ->
  #       try do
  #         {String.to_integer(value), ctx}
  #       rescue
  #         ArgumentError ->
  #           try do
  #             {String.to_float(value), ctx}
  #           rescue
  #             ArgumentError ->
  #               Error.comptime(ctx, distillation_error(value))
  #           end
  #       end
  #     value when is_comptime(value) ->
  #       # Should not really happen, the value should have been validated
  #       Error.comptime(ctx, error(:internal_error, "internal error"))
  #     ast ->
  #       # We assume the value is a string, it should have been validated
  #       {error, [var]} = Error.runtime(ctx, distillation_error/1)
  #       ast = quote do
  #         unquote(var) = unquote(ast)
  #         try do
  #           String.to_integer(unquote(var))
  #         rescue
  #           ArgumentError ->
  #             try do
  #               String.to_float(unquote(var))
  #             rescue
  #               ArgumentError -> unquote(error)
  #             end
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #   end
  # end


  # defp _meta_to_string(ast, ctx) do
  #   case ast do
  #     value when is_comptime(value) ->
  #       {to_string(value), ctx}
  #     ast ->
  #       {quote(do: to_string(unquote(ast))), ctx}
  #   end
  # end


  # defp _meta_validate_undefined(ast, ctx, _opts) do
  #   undefined_value = Context.undefined_value(ctx)
  #   {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
  #   case ast do
  #     ^undefined_value -> {undefined_value, ctx}
  #     {type, _, _} = value when type == :{} or type == :%{} ->
  #       Error.comptime(ctx, bad_value(value))
  #     value when is_list(value) ->
  #       Error.comptime(ctx, bad_value(value))
  #     value when is_comptime(value) ->
  #       Error.comptime(ctx, bad_value(value))
  #     ast ->
  #       ast = quote do
  #         case unquote(ast) do
  #           unquote(undefined_value) = result -> result
  #           unquote(bad_var) -> unquote(bad_ast)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #   end
  # end


# defp _meta_validate_atom(ast, ctx, _opts) do
#     case ast do
#       value when is_atom(value) and value != nil ->
#         {value, ctx}
#       {type, _, _} = value when type == :{} or type == :%{} ->
#         Error.comptime(ctx, bad_value(value))
#       value when is_list(value) ->
#         Error.comptime(ctx, bad_value(value))
#       value when is_comptime(value) ->
#         Error.comptime(ctx, bad_value(value))
#       ast ->
#         {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
#         ast = quote do
#           case unquote(ast) do
#             value when is_atom(value) and value != nil ->
#               value
#             unquote(bad_var) -> unquote(bad_ast)
#           end
#         end
#         {ast, Context.may_raise(ctx)}
#     end
#   end


  # defp _meta_validate_atom(ast, ctx, _opts) do
  #   case ast do
  #     value when is_atom(value) and value != nil ->
  #       {value, ctx}
  #     {type, _, _} = value when type == :{} or type == :%{} ->
  #       Error.comptime(ctx, bad_value(value))
  #     value when is_list(value) ->
  #       Error.comptime(ctx, bad_value(value))
  #     value when is_comptime(value) ->
  #       Error.comptime(ctx, bad_value(value))
  #     ast ->
  #       {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
  #       ast = quote do
  #         case unquote(ast) do
  #           value when is_atom(value) and value != nil ->
  #             value
  #           unquote(bad_var) -> unquote(bad_ast)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #   end
  # end


  # defp _meta_validate_boolean(ast, ctx, _opts) do
  #   case ast do
  #     value when is_boolean(value) -> {value, ctx}
  #     {type, _, _} = value when type == :{} or type == :%{} ->
  #       Error.comptime(ctx, bad_value(value))
  #     value when is_list(value) ->
  #       Error.comptime(ctx, bad_value(value))
  #     value when is_comptime(value) ->
  #       Error.comptime(ctx, bad_value(value))
  #     ast ->
  #       {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
  #       ast = quote do
  #         case unquote(ast) do
  #           value when is_boolean(value) -> value
  #           unquote(bad_var) -> unquote(bad_ast)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #   end
  # end


  # defp _meta_validate_number(ast, ctx, opts, guard_name \\ :is_number) do
  #   min_opt = Options.fetch(ctx, opts, :min)
  #   max_opt = Options.fetch(ctx, opts, :max)
  #   var = Macro.var(:value, __MODULE__)
  #   guard = {guard_name, [context: Elixir, import: Kernel], [var]}
  #   {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
  #   case {apply(Kernel, guard_name, [ast]), ast, min_opt, max_opt} do
  #     {true, num, :error, :error} -> {num, ctx}
  #     {true, num, {:ok, min}, :error}
  #      when num >= min -> {num, ctx}
  #     {true, num, {:ok, min}, :error} ->
  #       Error.comptime(ctx, value_too_small(num, min))
  #     {true, num, :error, {:ok, max}}
  #      when num <= max -> {num, ctx}
  #     {true, num, :error, {:ok, max}} ->
  #       Error.comptime(ctx, value_too_big(num, max))
  #     {true, num, {:ok, min}, {:ok, max}}
  #      when num >= min and num <= max -> {num, ctx}
  #     {true, num, {:ok, min}, {:ok, max}}
  #      when num >= min ->
  #       Error.comptime(ctx, value_too_big(num, max))
  #     {true, num, {:ok, min}, {:ok, _max}} ->
  #       Error.comptime(ctx, value_too_small(num, min))
  #     {false, {type, _, _} = value, _, _}
  #      when type == :{} or type == :%{} ->
  #       Error.comptime(ctx, bad_value(value))
  #     {false, value, _, _} when is_list(value) ->
  #       Error.comptime(ctx, bad_value(value))
  #     {false, value, _, _}
  #      when is_comptime(value) ->
  #       Error.comptime(ctx, bad_value(value))
  #     {false, ast, :error, :error} ->
  #       {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
  #       ast = quote do
  #         case unquote(ast) do
  #           unquote(var) when unquote(guard) ->
  #             unquote(var)
  #           unquote(bad_var) ->
  #             unquote(bad_ast)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #     {false, ast, {:ok, min}, :error} ->
  #       {small_ast, [small_var]} = Error.runtime(ctx, value_too_small(min)/1)
  #       ast = quote do
  #         case unquote(ast) do
  #           unquote(var) when unquote(guard)
  #            and unquote(var) >= unquote(min) ->
  #             unquote(var)
  #           unquote(small_var) = unquote(var) when unquote(guard) ->
  #             unquote(small_ast)
  #           unquote(bad_var) ->
  #             unquote(bad_ast)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #     {false, ast, :error, {:ok, max}} ->
  #       {big_ast, [big_var]} = Error.runtime(ctx, value_too_big(max)/1)
  #       ast = quote do
  #         case unquote(ast) do
  #           unquote(var) when unquote(guard)
  #            and unquote(var) <= unquote(max) ->
  #             unquote(var)
  #           unquote(big_var) = unquote(var) when unquote(guard) ->
  #             unquote(big_ast)
  #           unquote(bad_var) ->
  #             unquote(bad_ast)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #     {false, ast, {:ok, min}, {:ok, max}} ->
  #       {small_ast, [small_var]} = Error.runtime(ctx, value_too_small(min)/1)
  #       {big_ast, [big_var]} = Error.runtime(ctx, value_too_big(max)/1)
  #       ast = quote do
  #         case unquote(ast) do
  #           unquote(var) when unquote(guard)
  #            and unquote(var) >= unquote(min)
  #            and unquote(var) <= unquote(max) ->
  #             unquote(var)
  #           unquote(big_var) = unquote(var) when unquote(guard)
  #            and unquote(big_var) >= unquote(min) ->
  #             unquote(big_ast)
  #           unquote(small_var) = unquote(var) when unquote(guard) ->
  #             unquote(small_ast)
  #           unquote(bad_var) ->
  #             unquote(bad_ast)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #   end
  # end


  # defp _meta_validate_string(ast, ctx, _opts) do
  #   case ast do
  #     value when is_binary(value) ->
  #       case String.valid?(value) do
  #         false -> Error.comptime(ctx, bad_value(value))
  #         true -> {value, ctx}
  #       end
  #     {type, _, _} = value when type == :{} or type == :%{} ->
  #       Error.comptime(ctx, bad_value(value))
  #     value when is_list(value) ->
  #       Error.comptime(ctx, bad_value(value))
  #     value when is_comptime(value) ->
  #       Error.comptime(ctx, bad_value(value))
  #     ast ->
  #       {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
  #       ast = quote do
  #         case unquote(ast) do
  #           unquote(bad_var) when is_binary(unquote(bad_var)) ->
  #             case String.valid?(unquote(bad_var)) do
  #               true -> unquote(bad_var)
  #               false -> unquote(bad_ast)
  #             end
  #           unquote(bad_var) -> unquote(bad_ast)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #   end
  # end


  # defp _meta_validate_binary(ast, ctx, _opts) do
  #   case ast do
  #     value when is_binary(value) -> {value, ctx}
  #     {type, _, _} = value when type == :{} or type == :%{} ->
  #       Error.comptime(ctx, bad_value(value))
  #     value when is_list(value) ->
  #       Error.comptime(ctx, bad_value(value))
  #     value when is_comptime(value) ->
  #       Error.comptime(ctx, bad_value(value))
  #     ast ->
  #       {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
  #       ast = quote do
  #         case unquote(ast) do
  #           value when is_binary(value) -> value
  #           unquote(bad_var) -> unquote(bad_ast)
  #         end
  #       end
  #       {ast, Context.may_raise(ctx)}
  #   end
  # end

end