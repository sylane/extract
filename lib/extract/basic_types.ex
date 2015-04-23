defmodule Extract.BasicTypes do

  use Extract

  alias Extract.Meta
  alias Extract.Meta.Error
  alias Extract.Meta.Context
  alias Extract.Meta.Options
  alias Extract.Meta.Extracts

  @generate_validation :validate
  @generate_validation! :validate!


  # # extract_type :undefined, "undefined" do
  #   unquote(match_undefined) = value -> value
  #   value -> raise Error.bad_value(value)
  # end

  Extracts.register(:undefined, "undefined",
                    __MODULE__, :validate_undefined, [])

  # extract_type :atom, "atom", [:optional, :default, :allowed] do
  #   value when is_atom(value) and value != nil -> value
  #   value -> raise Error.bad_value(value)
  # end

  Extracts.register(:atom, "atom",
                    __MODULE__, :validate_atom,
                    [:optional, :default, :allowed])

  # extract_type :boolean, "boolean", [:optional, :default, :allowed] do
  #   value when is_boolean(value) -> value
  #   value -> raise Error.bad_value(value)
  # end

  Extracts.register(:boolean, "boolean",
                    __MODULE__, :validate_boolean,
                    [:optional, :default, :allowed])

  # extract_custom_type :integer, "integer",
  #   [:optional, :default, :allowed, :min, :max],
  #   validate_number_comptime(&is_integer/1),
  #   validate_number_runtime(:is_integer)

  Extracts.register(:integer, "integer",
                    __MODULE__, :validate_integer,
                    [:optional, :default, :allowed, :min, :max])

  # extract_custom_type :float, "float",
  #   [:optional, :default, :allowed, :min, :max],
  #   validate_number_comptime(&is_float/1),
  #   validate_number_runtime(:is_float)

  Extracts.register(:float, "float",
                    __MODULE__, :validate_float,
                    [:optional, :default, :allowed, :min, :max])

  # extract_custom_type :number, "number",
  #   [:optional, :default, :allowed, :min, :max],
  #   validate_number_comptime(&is_number/1),
  #   validate_number_runtime(:is_number)

  Extracts.register(:number, "number",
                    __MODULE__, :validate_number,
                    [:optional, :default, :allowed, :min, :max])

  # extract_type :string, "string", [:optional, :default, :allowed] do
  #   value when is_binary(value) ->
  #     case String.valid?(value) do
  #       true -> value
  #       false -> raise Error.bad_value(value)
  #     end
  #   value -> raise Error.bad_value(value)
  # end

  Extracts.register(:string, "string",
                    __MODULE__, :validate_string,
                    [:optional, :default, :allowed])

  # extract_type :binary, "binary", [:optional, :default, :allowed] do
  #   value when is_binary(value) -> value
  #   value -> raise Error.bad_value(value)
  # end

  Extracts.register(:binary, "binary",
                    __MODULE__, :validate_binary,
                    [:optional, :default, :allowed])

  # defmeta validate_number_comptime(ast, ctx, opts, type_checker) do
  #   min_opt = Options.fetch(ctx, opts, :min)
  #   max_opt = Options.fetch(ctx, opts, :max)
  #   new_ast = case {min_opt, max_opt} do
  #     {:error, :error} ->
  #       case {type_checker.(ast), ast} do
  #         {true, value} -> value
  #         {false, value }-> Error.comptime(ctx, bad_value(value))
  #       end
  #     {{:ok, min}, :error} ->
  #       case {type_checker.(ast), ast} do
  #         {true, value} when value >= min -> value
  #         {true, value} -> Error.comptime(ctx, value_too_small(value, min))
  #         {false, value} -> Error.comptime(ctx, bad_value(value))
  #       end
  #     {:error, {:ok, max}} ->
  #       case {type_checker.(ast), ast} do
  #         {true, value} when value <= max -> value
  #         {true, value} -> Error.comptime(ctx, value_too_big(value, max))
  #         {false, value} -> Error.comptime(ctx, bad_value(value))
  #       end
  #     {{:ok, min}, {:ok, max}} ->
  #       case {type_checker.(ast), ast} do
  #         {true, value} when value >= min and value <= max -> value
  #         {true, value} when value >= min ->
  #           Error.comptime(ctx, value_too_big(value, max))
  #         {true, value} -> Error.comptime(ctx, value_too_small(value, min))
  #         {false, value} -> Error.comptime(ctx, bad_value(value))
  #       end
  #   end
  #   {new_ast, ctx}
  # end


  # defmeta validate_number_runtime(ast, ctx, opts, guard_name) do
  #   min_opt = Options.fetch(ctx, opts, :min)
  #   max_opt = Options.fetch(ctx, opts, :max)
  #   var = Macro.var(:value, __MODULE__)
  #   guard = {guard_name, [context: Elixir, import: Kernel], [var]}
  #   {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
  #   new_ast = case {min_opt, max_opt} do
  #     {:error, :error} ->
  #       quote do
  #         case unquote(ast) do
  #           unquote(var) when unquote(guard) -> unquote(var)
  #           unquote(bad_var) -> unquote(bad_ast)
  #         end
  #       end
  #     {{:ok, min}, :error} ->
  #       {error_ast, [error_var]} = Error.runtime(ctx, value_too_small(min)/1)
  #       quote do
  #         case unquote(ast) do
  #           unquote(var) when unquote(guard) and unquote(var) >= unquote(min) ->
  #             unquote(var)
  #           unquote(var) = unquote(error_var) when unquote(guard) ->
  #             unquote(error_ast)
  #           unquote(bad_var) -> unquote(bad_ast)
  #         end
  #       end
  #     {:error, {:ok, max}} ->
  #       {error_ast, [error_var]} = Error.runtime(ctx, value_too_big(max)/1)
  #       quote do
  #         case unquote(ast) do
  #           unquote(var) when unquote(guard) and unquote(var) <= unquote(max) ->
  #             unquote(var)
  #           unquote(var) = unquote(error_var) when unquote(guard) ->
  #             unquote(error_ast)
  #           unquote(bad_var) -> unquote(bad_ast)
  #         end
  #       end
  #     {{:ok, min}, {:ok, max}} ->
  #       {small_error, [small_var]} = Error.runtime(ctx, value_too_small(min)/1)
  #       {big_error, [big_var]} = Error.runtime(ctx, value_too_big(max)/1)
  #       quote do
  #         case unquote(ast) do
  #           unquote(var) when unquote(guard)
  #            and unquote(var) >= unquote(min)
  #            and unquote(var) <= unquote(max) ->
  #             unquote(var)
  #           unquote(var) = unquote(big_var) when unquote(guard)
  #            and unquote(var) >= unquote(min) ->
  #             unquote(big_error)
  #           unquote(var) = unquote(small_var) when unquote(guard) ->
  #             unquote(small_error)
  #           unquote(bad_var) -> unquote(bad_ast)
  #         end
  #       end
  #   end
  #   {new_ast, Context.may_raise(ctx)}
  # end

  # receipt_statment :float, :integer, "float to integer" do
  #   value when is_float(value) -> round(value)
  #   value -> raise Error.bad_value(value)
  # end

  # Extract.register_receipt({:float, :integer}, "float to integer",
  #                          :distill_float_to_integer)

  defmodule Meta do

    def validate_undefined(ast, ctx, opts, body) do
      pipeline ast, ctx do
        Extract.Meta.type_info :undefined, "undefined"
        Extract.Meta.allowed_options opts, []
        Extract.Meta.assert_undefined_body body
        condition Extract.Meta.comptime? do
          validate_undefined_comptime opts
        else
          validate_undefined_runtime opts
        end
      end
    end


    def validate_undefined_comptime(ast, ctx, _opts) do
      undefined_value = Context.undefined_value(ctx)
      new_ast = case ast do
        ^undefined_value = value -> value
        value -> Error.comptime(ctx, bad_value(value))
      end
      {new_ast, ctx}
    end


    def validate_undefined_runtime(ast, ctx, _opts) do
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

    def validate_atom(ast, ctx, opts, body) do
      pipeline ast, ctx do
        Extract.Meta.type_info :atom, "atom"
        Extract.Meta.allowed_options opts, [:optional, :default, :allowed]
        Extract.Meta.assert_undefined_body body
        condition Extract.Meta.defined?(opts) do
          condition Extract.Meta.comptime? do
            validate_atom_comptime opts
          else
            validate_atom_runtime opts
          end
          Extract.Meta.allowed_value opts
        end
      end
    end


    def validate_atom_comptime(ast, ctx, _opts) do
      new_ast = case ast do
        value when is_atom(value) and value != nil -> value
        value -> Error.comptime(ctx, bad_value(value))
      end
      {new_ast, ctx}
    end


    def validate_atom_runtime(ast, ctx, _opts) do
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


    def validate_boolean(ast, ctx, opts, body) do
      pipeline ast, ctx do
        Extract.Meta.type_info :boolean, "boolean"
        Extract.Meta.allowed_options opts, [:optional, :default, :allowed]
        Extract.Meta.assert_undefined_body body
        condition Extract.Meta.defined?(opts) do
          condition Extract.Meta.comptime? do
            validate_boolean_comptime opts
          else
            validate_boolean_runtime opts
          end
          Extract.Meta.allowed_value opts
        end
      end
    end


    def validate_boolean_comptime(ast, ctx, _opts) do
      new_ast = case ast do
        value when is_boolean(value) -> value
        value -> Error.comptime(ctx, bad_value(value))
      end
      {new_ast, ctx}
    end


    def validate_boolean_runtime(ast, ctx, _opts) do
      {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
      new_ast = quote do
        case unquote(ast) do
          value when is_boolean(value) -> value
          unquote(bad_var) -> unquote(bad_ast)
        end
      end
      {new_ast, Context.may_raise(ctx)}
    end


    def validate_integer(ast, ctx, opts, body) do
      #FIXME: implement multi_fetch ?
      checked_opts = [Options.fetch(ctx, opts, :min),
                      Options.fetch(ctx, opts, :min)]
      pipeline ast, ctx do
        Extract.Meta.type_info :integer, "integer"
        Extract.Meta.allowed_options opts, [:optional, :default, :allowed, :min, :max]
        Extract.Meta.assert_undefined_body body
        condition Extract.Meta.defined?(opts) do
          condition Extract.Meta.comptime? checked_opts do
            validate_number_comptime opts, &is_integer/1
          else
            validate_number_runtime opts, :is_integer
          end
          Extract.Meta.allowed_value opts
        end
      end
    end


    def validate_float(ast, ctx, opts, body) do
      checked_opts = [Options.fetch(ctx, opts, :min),
                      Options.fetch(ctx, opts, :min)]
      pipeline ast, ctx do
        Extract.Meta.type_info :float, "float"
        Extract.Meta.allowed_options opts, [:optional, :default, :allowed, :min, :max]
        Extract.Meta.assert_undefined_body body
        condition Extract.Meta.defined?(opts) do
          condition Extract.Meta.comptime? checked_opts do
            validate_number_comptime opts, &is_float/1
          else
            validate_number_runtime opts, :is_float
          end
          Extract.Meta.allowed_value opts
        end
      end
    end


    def validate_number(ast, ctx, opts, body) do
      checked_opts = [Options.fetch(ctx, opts, :min),
                      Options.fetch(ctx, opts, :min)]
      pipeline ast, ctx do
        Extract.Meta.type_info :number, "number"
        Extract.Meta.allowed_options opts, [:optional, :default, :allowed, :min, :max]
        Extract.Meta.assert_undefined_body body
        condition Extract.Meta.defined?(opts) do
          condition Extract.Meta.comptime? checked_opts do
            validate_number_comptime opts, &is_number/1
          else
            validate_number_runtime opts, :is_number
          end
          Extract.Meta.allowed_value opts
        end
      end
    end


    def validate_string(ast, ctx, opts, body) do
      pipeline ast, ctx do
        Extract.Meta.type_info :string, "string"
        Extract.Meta.allowed_options opts, [:optional, :default, :allowed]
        Extract.Meta.assert_undefined_body body
        condition Extract.Meta.defined?(opts) do
          condition Extract.Meta.comptime? do
            validate_string_comptime opts
          else
            validate_string_runtime opts
          end
          Extract.Meta.allowed_value opts
        end
      end
    end


    def validate_string_comptime(ast, ctx, _opts) do
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


    def validate_string_runtime(ast, ctx, _opts) do
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


    def validate_binary(ast, ctx, opts, body) do
      pipeline ast, ctx do
        Extract.Meta.type_info :binary, "binary"
        Extract.Meta.allowed_options opts, [:optional, :default, :allowed]
        Extract.Meta.assert_undefined_body body
        condition Extract.Meta.defined?(opts) do
          condition Extract.Meta.comptime? do
            validate_binary_comptime opts
          else
            validate_binary_runtime opts
          end
          Extract.Meta.allowed_value opts
        end
      end
    end


    def validate_binary_comptime(ast, ctx, _opts) do
      new_ast = case ast do
        value when is_binary(value) -> value
        value -> Error.comptime(ctx, bad_value(value))
      end
      {new_ast, ctx}
    end


    def validate_binary_runtime(ast, ctx, _opts) do
      {error_ast, [error_var]} = Error.runtime(ctx, bad_value/1)
      new_ast = quote do
        case unquote(ast) do
          value when is_binary(value) -> value
          unquote(error_var) -> unquote(error_ast)
        end
      end
      {new_ast, Context.may_raise(ctx)}
    end


    def validate_number_comptime(ast, ctx, opts, type_checker) do
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


    def validate_number_runtime(ast, ctx, opts, guard_name) do
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

  end

  #   def distill_float_to_integer(ast, ctx, opts, body) do
  #     pipeline ast, ctx do
  #       Extract.Meta.type_info :integer, "integer"
  #       condition Extract.Meta.comptime? do
  #          distill_float_to_integer_comptime opts
  #        else
  #          distill_float_to_integer_runtime opts
  #       end
  #       Extract.validate! :integer, opts, body
  #     end
  #   end


  #   defp distill_float_to_integer_comptime(ast, ctx, _opts) do
  #     new_ast = case ast do
  #       value when is_float(value) -> round(value)
  #       value -> Error.comptime(ctx, distillation_error(value))
  #     end
  #     {new_ast, ctx}
  #   end


  #   defp distill_float_to_integer_runtime(ast, ctx, _opts) do
  #     {error_ast, [error_var]} = Error.runtime(ctx, distillation_error/1)
  #     new_ast = quote do
  #       case unquote(ast) do
  #         value when is_float(value) -> round(value)
  #         unquote(error_var) -> unquote(error_ast)
  #       end
  #     end
  #     {new_ast, Context.may_raise(ctx)}
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

end