defmodule Extract.BasicTypes do

  use Extract

  alias Extract.Meta
  alias Extract.Meta.Error
  alias Extract.Meta.Context
  alias Extract.Meta.Options
  alias Extract.Meta.Extracts
  alias Extract.Meta.Receipts


  @generate_validation :validate
  @generate_validation! :validate!

  # The registrations are supposed to be generated

  # extract_statement :undefined, "undefined" do
  #   @match_undefined = value -> value
  #   value -> raise Error.bad_value(value)
  # end

  Extracts.register(:undefined, "undefined",
                    __MODULE__, :validate_undefined, [])

  Receipts.register(:undefined, :undefined, "undefined to undefined",
                    __MODULE__, :distill_undefined_to_undefined)

  # extract_statement :atom, "atom", [:optional, :default, :allowed] do
  #   value when is_atom(value) and value != nil -> value
  #   value -> raise Error.bad_value(value)
  # end

  Extracts.register(:atom, "atom",
                    __MODULE__, :validate_atom,
                    [:optional, :default, :allowed])

  Receipts.register(:atom, :atom, "atom to atom",
                    __MODULE__, :distill_atom_to_atom)

  # extract_statement :boolean, "boolean", [:optional, :default, :allowed] do
  #   value when is_boolean(value) -> value
  #   value -> raise Error.bad_value(value)
  # end

  Extracts.register(:boolean, "boolean",
                    __MODULE__, :validate_boolean,
                    [:optional, :default, :allowed])

  Receipts.register(:boolean, :boolean, "boolean to boolean",
                    __MODULE__, :distill_boolean_to_boolean)

  # extract_custom_statement :integer, "integer",
  #   [:optional, :default, :allowed, :min, :max],
  #   :validate_number_comptime, validate_number_runtime

  Extracts.register(:integer, "integer",
                    __MODULE__, :validate_integer,
                    [:optional, :default, :allowed, :min, :max])

  Receipts.register(:integer, :integer, "integer to integer",
                    __MODULE__, :distill_integer_to_integer)

  # extract_custom_statement :float, "float",
  #   [:optional, :default, :allowed, :min, :max],
  #   :validate_number_comptime, validate_number_runtime

  Extracts.register(:float, "float",
                    __MODULE__, :validate_float,
                    [:optional, :default, :allowed, :min, :max])

  Receipts.register(:float, :float, "float to float",
                    __MODULE__, :distill_float_to_float)

  # extract_custom_statement :number, "number",
  #   [:optional, :default, :allowed, :min, :max],
  #   :validate_number_comptime, validate_number_runtime

  Extracts.register(:number, "number",
                    __MODULE__, :validate_number,
                    [:optional, :default, :allowed, :min, :max])

  Receipts.register(:number, :number, "number to number",
                    __MODULE__, :distill_number_to_number)

  # extract_statement :string, "string", [:optional, :default, :allowed] do
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

  Receipts.register(:string, :string, "string to string",
                    __MODULE__, :distill_string_to_string)

  # extract_statement :binary, "binary", [:optional, :default, :allowed] do
  #   value when is_binary(value) -> value
  #   value -> raise Error.bad_value(value)
  # end

  Extracts.register(:binary, "binary",
                    __MODULE__, :validate_binary,
                    [:optional, :default, :allowed])

  Receipts.register(:binary, :binary, "binary to binary",
                    __MODULE__, :distill_binary_to_binary)


  # # receipt_statment any, :undefined, "#{from} to undefined"

  # Receipts.register(:atom, :undefined, "atom to undefined",
  #                   __MODULE__, :distill_atom_to_undefined)

  # Receipts.register(:boolean, :undefined, "boolean to undefined",
  #                   __MODULE__, :distill_boolean_to_undefined)

  # Receipts.register(:integer, :undefined, "integer to undefined",
  #                   __MODULE__, :distill_integer_to_undefined)

  # Receipts.register(:float, :undefined, "float to undefined",
  #                   __MODULE__, :distill_float_to_undefined)

  # Receipts.register(:number, :undefined, "number to undefined",
  #                   __MODULE__, :distill_number_to_undefined)

  # Receipts.register(:string, :undefined, "string to undefined",
  #                   __MODULE__, :distill_string_to_undefined)

  # Receipts.register(:binary, :undefined, "binary to undefined",
  #                   __MODULE__, :distill_binary_to_undefined)


  # # receipt_statment :undefined, any, "undefined to #{to}"

  # Receipts.register(:undefined, :atom, "undefined to atom",
  #                   __MODULE__, :distill_undefined_to_atom)

  # Receipts.register(:undefined, :boolean, "undefined to boolean",
  #                   __MODULE__, :distill_undefined_to_boolean)

  # Receipts.register(:undefined, :integer, "undefined to integer",
  #                   __MODULE__, :distill_undefined_to_integer)

  # Receipts.register(:undefined, :float, "undefined to float",
  #                   __MODULE__, :distill_undefined_to_float)

  # Receipts.register(:undefined, :number, "undefined to number",
  #                   __MODULE__, :distill_undefined_to_number)

  # Receipts.register(:undefined, :string, "undefined to string",
  #                   __MODULE__, :distill_undefined_to_string)

  # Receipts.register(:undefined, :binary, "undefined to binary",
  #                   __MODULE__, :distill_undefined_to_binary)


  # # receipt_statment :boolean, :atom, "boolean to atom"

  # Receipts.register(:boolean, :atom, "boolean to atom",
  #                   __MODULE__, :distill_boolean_to_atom)

  # # receipt_statment :string, :atom, "string to atom" do
  # #   try do
  # #     String.to_existing_atom(value)
  # #   rescue
  # #     ArgumentError ->
  # #       raise Error.value_not_allowed(value)
  # #   end
  # # end

  # Receipts.register(:string, :atom, "string to atom",
  #                   __MODULE__, :distill_string_to_atom)

  # # receipt_statment :atom, :boolean, "atom to boolean" do
  # #   true -> true
  # #   false -> false
  # #   value -> raise Error.bad_value(value)
  # # end

  # Receipts.register(:atom, :boolean, "atom to boolean",
  #                   __MODULE__, :distill_atom_to_boolean)

  # # receipt_statment :string, :boolean, "string to boolean" do
  # #   "true" -> true
  # #   "false" -> false
  # #   value -> raise Error.bad_value(value)
  # # end

  # Receipts.register(:string, :boolean, "string to boolean",
  #                   __MODULE__, :distill_string_to_boolean)

  # # receipt_statment :float, :integer, "float to integer" do
  # #   round(value)
  # # end

  # Receipts.register(:float, :integer, "float to integer",
  #                   __MODULE__, :distill_float_to_integer)

  # # receipt_statment :number, :integer, "number to integer"

  # Receipts.register(:number, :integer, "number to integer",
  #                   __MODULE__, :distill_number_to_integer)


  # # receipt_statment :integer, :float, "integer to float" do
  # #   value / 1
  # # end

  # Receipts.register(:integer, :float, "integer to float",
  #                   __MODULE__, :distill_integer_to_float)

  # # receipt_statment :number, :float, "number to flolat"

  # Receipts.register(:number, :float, "number to float",
  #                   __MODULE__, :distill_number_to_float)


  # # receipt_statment [:integer, :float], :number, "#{from} to number"

  # Receipts.register(:integer, :number, "integer to number",
  #                   __MODULE__, :distill_integer_to_number)

  # Receipts.register(:float, :number, "float to number",
  #                   __MODULE__, :distill_float_to_number)

  # # receipt_statment [:atom, :boolean, :integer, :float, :number], :string,
  # #                  "#{from} to string" do
  # #   to_string(value)
  # # end

  # Receipts.register(:atom, :string, "atom to string",
  #                   __MODULE__, :distill_atom_to_string)

  # Receipts.register(:boolean, :string, "boolean to string",
  #                   __MODULE__, :distill_boolean_to_string)

  # Receipts.register(:integer, :string, "integer to string",
  #                   __MODULE__, :distill_integer_to_string)

  # Receipts.register(:float, :string, "float to string",
  #                   __MODULE__, :distill_float_to_string)

  # Receipts.register(:number, :string, "number to string",
  #                   __MODULE__, :distill_number_to_string)

  # # receipt_statment :binary, :string, "binary to string"

  # Receipts.register(:binary, :string, "binary to string",
  #                   __MODULE__, :distill_binary_to_string)


  # # receipt_statment :string, :binary, "string to binary"

  # Receipts.register(:string, :binary, "string to binary",
  #                   __MODULE__, :distill_string_to_binary)


  # # defmeta validate_number_comptime(ast, ctx, format, opts, _body) do
  # #   type_checker = case format do
  # #     :integer -> &is_integer/1
  # #     :float -> &is_float/1
  # #     :number -> &is_number/1
  # #   end
  # #   min_opt = Options.fetch(ctx, opts, :min)
  # #   max_opt = Options.fetch(ctx, opts, :max)
  # #   new_ast = case {min_opt, max_opt} do
  # #     {:error, :error} ->
  # #       case {type_checker.(ast), ast} do
  # #         {true, value} -> value
  # #         {false, value }-> Error.comptime(ctx, bad_value(value))
  # #       end
  # #     {{:ok, min}, :error} ->
  # #       case {type_checker.(ast), ast} do
  # #         {true, value} when value >= min -> value
  # #         {true, value} -> Error.comptime(ctx, value_too_small(value, min))
  # #         {false, value} -> Error.comptime(ctx, bad_value(value))
  # #       end
  # #     {:error, {:ok, max}} ->
  # #       case {type_checker.(ast), ast} do
  # #         {true, value} when value <= max -> value
  # #         {true, value} -> Error.comptime(ctx, value_too_big(value, max))
  # #         {false, value} -> Error.comptime(ctx, bad_value(value))
  # #       end
  # #     {{:ok, min}, {:ok, max}} ->
  # #       case {type_checker.(ast), ast} do
  # #         {true, value} when value >= min and value <= max -> value
  # #         {true, value} when value >= min ->
  # #           Error.comptime(ctx, value_too_big(value, max))
  # #         {true, value} -> Error.comptime(ctx, value_too_small(value, min))
  # #         {false, value} -> Error.comptime(ctx, bad_value(value))
  # #       end
  # #   end
  # #   {new_ast, ctx}
  # # end


  # # defmeta validate_number_runtime(ast, ctx, format, opts, _body) do
  # #   guard = case format do
  # #     :integer -> {is_integer, [context: Elixir, import: Kernel], [var]}
  # #     :float -> {is_float, [context: Elixir, import: Kernel], [var]}
  # #     :number -> {is_number, [context: Elixir, import: Kernel], [var]}
  # #   end
  # #   min_opt = Options.fetch(ctx, opts, :min)
  # #   max_opt = Options.fetch(ctx, opts, :max)
  # #   var = Macro.var(:value, __MODULE__)
  # #   {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
  # #   new_ast = case {min_opt, max_opt} do
  # #     {:error, :error} ->
  # #       quote do
  # #         case unquote(ast) do
  # #           unquote(var) when unquote(guard) -> unquote(var)
  # #           unquote(bad_var) -> unquote(bad_ast)
  # #         end
  # #       end
  # #     {{:ok, min}, :error} ->
  # #       {error_ast, [error_var]} = Error.runtime(ctx, value_too_small(min)/1)
  # #       quote do
  # #         case unquote(ast) do
  # #           unquote(var)
  # #            when unquote(guard) and unquote(var) >= unquote(min) ->
  # #             unquote(var)
  # #           unquote(var) = unquote(error_var) when unquote(guard) ->
  # #             unquote(error_ast)
  # #           unquote(bad_var) -> unquote(bad_ast)
  # #         end
  # #       end
  # #     {:error, {:ok, max}} ->
  # #       {error_ast, [error_var]} = Error.runtime(ctx, value_too_big(max)/1)
  # #       quote do
  # #         case unquote(ast) do
  # #           unquote(var)
  # #            when unquote(guard) and unquote(var) <= unquote(max) ->
  # #             unquote(var)
  # #           unquote(var) = unquote(error_var) when unquote(guard) ->
  # #             unquote(error_ast)
  # #           unquote(bad_var) -> unquote(bad_ast)
  # #         end
  # #       end
  # #     {{:ok, min}, {:ok, max}} ->
  # #       {small_err, [small_var]} = Error.runtime(ctx, value_too_small(min)/1)
  # #       {big_err, [big_var]} = Error.runtime(ctx, value_too_big(max)/1)
  # #       quote do
  # #         case unquote(ast) do
  # #           unquote(var) when unquote(guard)
  # #            and unquote(var) >= unquote(min)
  # #            and unquote(var) <= unquote(max) ->
  # #             unquote(var)
  # #           unquote(var) = unquote(big_var) when unquote(guard)
  # #            and unquote(var) >= unquote(min) ->
  # #             unquote(big_err)
  # #           unquote(var) = unquote(small_var) when unquote(guard) ->
  # #             unquote(small_err)
  # #           unquote(bad_var) -> unquote(bad_ast)
  # #         end
  # #       end
  # #   end
  # #   {new_ast, Context.may_raise(ctx)}
  # # end


  defmodule Meta do

    # This module is supposed to be generated

    alias Extract.Meta


    def validate_undefined(ast, ctx, :undefined, opts, body) do
      pipeline ast, ctx do
        condition Meta.is_current_format? :undefined do
          Meta.allowed_options opts, []
          Meta.assert_undefined_body body
        else
          Meta.push_extract :undefined, "undefined"
          Meta.allowed_options opts, []
          Meta.assert_undefined_body body
          condition Meta.is_comptime? nil do
            validate_undefined_comptime opts
          else
            validate_undefined_runtime opts
          end
          Meta.set_format :undefined
        end
      end
    end


    def distill_undefined_to_undefined(ast, ctx,
     :undefined, from_opts, from_body, :undefined, to_opts, to_body) do
      pipeline ast, ctx do
        Meta.push_receipt :undefined, :undefined, "undefined to undefined"
        Extract._validate! :undefined, from_opts, from_body
        Extract._validate! :undefined, to_opts, to_body
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


    def validate_atom(ast, ctx, :atom, opts, body) do
      pipeline ast, ctx do
        condition Meta.is_current_format? :atom do
          Meta.allowed_options opts, [:optional, :default, :allowed]
          Meta.assert_undefined_body body
          condition Meta.defined? opts do
            Meta.allowed_value opts
          end
        else
          Meta.push_extract :atom, "atom"
          Meta.allowed_options opts, [:optional, :default, :allowed]
          Meta.assert_undefined_body body
          condition Meta.defined? opts do
            condition Meta.is_comptime? nil do
              validate_atom_comptime
            else
              validate_atom_runtime
            end
            Meta.allowed_value opts
          end
          Meta.set_format :atom
        end
      end
    end


    def distill_atom_to_atom(ast, ctx,
     :atom, from_opts, from_body, :atom, to_opts, to_body) do
      pipeline ast, ctx do
        Meta.push_receipt :atom, :atom, "atom to atom"
        Extract._validate! :atom, from_opts, from_body
        Extract._validate! :atom, to_opts, to_body
      end
    end


    def validate_atom_comptime(ast, ctx) do
      new_ast = case ast do
        value when is_atom(value) and value != nil -> value
        value -> Error.comptime(ctx, bad_value(value))
      end
      {new_ast, ctx}
    end


    def validate_atom_runtime(ast, ctx) do
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


    def validate_boolean(ast, ctx, :boolean, opts, body) do
      pipeline ast, ctx do
        condition Meta.is_current_format? :boolean do
          Meta.allowed_options opts, [:optional, :default, :allowed]
          Meta.assert_undefined_body body
          condition Meta.defined? opts do
            Meta.allowed_value opts
          end
        else
          Meta.push_extract :boolean, "boolean"
          Meta.allowed_options opts, [:optional, :default, :allowed]
          Meta.assert_undefined_body body
          condition Meta.defined? opts do
            condition Meta.is_comptime? nil do
              validate_boolean_comptime
            else
              validate_boolean_runtime
            end
            Meta.allowed_value opts
          end
          Meta.set_format :boolean
        end
      end
    end


    def distill_boolean_to_boolean(ast,
     ctx, :boolean, from_opts, from_body, :boolean, to_opts, to_body) do
      pipeline ast, ctx do
        Meta.push_receipt :boolean, :boolean, "boolean to boolean"
        Extract._validate! :boolean, from_opts, from_body
        Extract._validate! :boolean, to_opts, to_body
      end
    end


    def validate_boolean_comptime(ast, ctx) do
      new_ast = case ast do
        value when is_boolean(value) -> value
        value -> Error.comptime(ctx, bad_value(value))
      end
      {new_ast, ctx}
    end


    def validate_boolean_runtime(ast, ctx) do
      {bad_ast, [bad_var]} = Error.runtime(ctx, bad_value/1)
      new_ast = quote do
        case unquote(ast) do
          value when is_boolean(value) -> value
          unquote(bad_var) -> unquote(bad_ast)
        end
      end
      {new_ast, Context.may_raise(ctx)}
    end


    def validate_integer(ast, ctx, :integer, opts, body) do
      #FIXME: implement multi_fetch ?
      checked_opts = [Options.fetch(ctx, opts, :min),
                      Options.fetch(ctx, opts, :min)]
      pipeline ast, ctx do
        Meta.push_extract :integer, "integer"
        Meta.allowed_options opts, [:optional, :default, :allowed, :min, :max]
        condition Meta.defined? opts do
          condition Meta.is_comptime? checked_opts do
            validate_number_comptime :integer, opts, body
          else
            validate_number_runtime :integer, opts, body
          end
          Meta.allowed_value opts
        end
        Meta.set_format :integer
      end
    end


    def distill_integer_to_integer(ast, ctx,
     :integer, from_opts, from_body, :integer, to_opts, to_body) do
      pipeline ast, ctx do
        Meta.push_receipt :integer, :integer, "integer to integer"
        Extract._validate! :integer, from_opts, from_body
        Extract._validate! :integer, to_opts, to_body
      end
    end


    def validate_float(ast, ctx, :float, opts, body) do
      checked_opts = [Options.fetch(ctx, opts, :min),
                      Options.fetch(ctx, opts, :min)]
      pipeline ast, ctx do
        Meta.push_extract :float, "float"
        Meta.allowed_options opts, [:optional, :default, :allowed, :min, :max]
        condition Meta.defined? opts do
          condition Meta.is_comptime? checked_opts do
            validate_number_comptime :float, opts, body
          else
            validate_number_runtime :float, opts, body
          end
          Meta.allowed_value opts
        end
        Meta.set_format :float
      end
    end


    def distill_float_to_float(ast, ctx,
     :float, from_opts, from_body, :float, to_opts, to_body) do
      pipeline ast, ctx do
        Meta.push_receipt :float, :float, "float to float"
        Extract._validate! :float, from_opts, from_body
        Extract._validate! :float, to_opts, to_body
      end
    end


    def validate_number(ast, ctx, :number, opts, body) do
      checked_opts = [Options.fetch(ctx, opts, :min),
                      Options.fetch(ctx, opts, :min)]
      pipeline ast, ctx do
        Meta.push_extract :number, "number"
        Meta.allowed_options opts, [:optional, :default, :allowed, :min, :max]
        condition Meta.defined? opts do
          condition Meta.is_comptime? checked_opts do
            validate_number_comptime :number, opts, body
          else
            validate_number_runtime :number, opts, body
          end
          Meta.allowed_value opts
        end
        Meta.set_format :number
      end
    end


    def distill_number_to_number(ast, ctx,
     :number, from_opts, from_body, :number, to_opts, to_body) do
      pipeline ast, ctx do
        Meta.push_receipt :number, :number, "number to number"
        Extract._validate! :number, from_opts, from_body
        Extract._validate! :number, to_opts, to_body
      end
    end


    def validate_string(ast, ctx, :string, opts, body) do
      pipeline ast, ctx do
        condition Meta.is_current_format? :string do
          Meta.allowed_options opts, [:optional, :default, :allowed]
          Meta.assert_undefined_body body
          condition Meta.defined? opts do
            Meta.allowed_value opts
          end
        else
          Meta.push_extract :string, "string"
          Meta.allowed_options opts, [:optional, :default, :allowed]
          Meta.assert_undefined_body body
          condition Meta.defined? opts do
            condition Meta.is_comptime? nil do
              validate_string_comptime
            else
              validate_string_runtime
            end
            Meta.allowed_value opts
          end
          Meta.set_format :string
        end
      end
    end


    def distill_string_to_string(ast, ctx,
     :string, from_opts, from_body, :string, to_opts, to_body) do
      pipeline ast, ctx do
        Meta.push_receipt :string, :string, "string to string"
        Extract._validate! :string, from_opts, from_body
        Extract._validate! :string, to_opts, to_body
      end
    end


    def validate_string_comptime(ast, ctx) do
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


    def validate_string_runtime(ast, ctx) do
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


    def validate_binary(ast, ctx, :binary, opts, body) do
      pipeline ast, ctx do
        condition Meta.is_current_format? :binary do
          Meta.allowed_options opts, [:optional, :default, :allowed]
          Meta.assert_undefined_body body
          condition Meta.defined? opts do
            Meta.allowed_value opts
          end
        else
          Meta.push_extract :binary, "binary"
          Meta.allowed_options opts, [:optional, :default, :allowed]
          Meta.assert_undefined_body body
          condition Meta.defined? opts do
            condition Meta.is_comptime? nil do
              validate_binary_comptime
            else
              validate_binary_runtime
            end
            Meta.allowed_value opts
          end
          Meta.set_format :binary
        end
      end
    end


    def distill_binary_to_binary(ast, ctx,
     :binary, from_opts, from_body, :binary, to_opts, to_body) do
      pipeline ast, ctx do
        Meta.push_receipt :binary, :binary, "binary to binary"
        Extract._validate! :binary, from_opts, from_body
        Extract._validate! :binary, to_opts, to_body
      end
    end


    def validate_binary_comptime(ast, ctx) do
      new_ast = case ast do
        value when is_binary(value) -> value
        value -> Error.comptime(ctx, bad_value(value))
      end
      {new_ast, ctx}
    end


    def validate_binary_runtime(ast, ctx) do
      {error_ast, [error_var]} = Error.runtime(ctx, bad_value/1)
      new_ast = quote do
        case unquote(ast) do
          value when is_binary(value) -> value
          unquote(error_var) -> unquote(error_ast)
        end
      end
      {new_ast, Context.may_raise(ctx)}
    end


    def validate_number_comptime(ast, ctx, format, opts, body) do
      Meta.assert_undefined_body(ast, ctx, body)
      type_checker = case format do
        :integer -> &is_integer/1
        :float -> &is_float/1
        :number -> &is_number/1
      end
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


    def validate_number_runtime(ast, ctx, format, opts, body) do
      Meta.assert_undefined_body(ast, ctx, body)
      var = Macro.var(:value, __MODULE__)
      guard = case format do
        :integer -> {:is_integer, [context: Elixir, import: Kernel], [var]}
        :float -> {:is_float, [context: Elixir, import: Kernel], [var]}
        :number -> {:is_number, [context: Elixir, import: Kernel], [var]}
      end
      min_opt = Options.fetch(ctx, opts, :min)
      max_opt = Options.fetch(ctx, opts, :max)
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
              unquote(var)
               when unquote(guard) and unquote(var) >= unquote(min) ->
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
              unquote(var)
               when unquote(guard) and unquote(var) <= unquote(max) ->
                unquote(var)
              unquote(var) = unquote(error_var) when unquote(guard) ->
                unquote(error_ast)
              unquote(bad_var) -> unquote(bad_ast)
            end
          end
        {{:ok, min}, {:ok, max}} ->
          {small_err, [small_var]} = Error.runtime(ctx, value_too_small(min)/1)
          {big_err, [big_var]} = Error.runtime(ctx, value_too_big(max)/1)
          quote do
            case unquote(ast) do
              unquote(var) when unquote(guard)
               and unquote(var) >= unquote(min)
               and unquote(var) <= unquote(max) ->
                unquote(var)
              unquote(var) = unquote(big_var) when unquote(guard)
               and unquote(var) >= unquote(min) ->
                unquote(big_err)
              unquote(var) = unquote(small_var) when unquote(guard) ->
                unquote(small_err)
              unquote(bad_var) -> unquote(bad_ast)
            end
          end
      end
      {new_ast, Context.may_raise(ctx)}
    end


    # def distill_atom_to_undefined(ast, ctx,
    #  :atom, from_opts, from_body, :undefined, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :atom, :undefined, "atom to undefined"
    #     Extract._validate! :atom, from_opts, from_body
    #     Extract._validate! :undefined, to_opts, to_body
    #   end
    # end


    # def distill_boolean_to_undefined(ast, ctx,
    #  :boolean, from_opts, from_body, :undefined, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :boolean, :undefined, "boolean to undefined"
    #     Extract._validate! :boolean, from_opts, from_body
    #     Extract._validate! :undefined, to_opts, to_body
    #   end
    # end


    # def distill_integer_to_undefined(ast, ctx,
    #  :integer, from_opts, from_body, :undefined, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :integer, :undefined, "integer to undefined"
    #     Extract._validate! :integer, from_opts, from_body
    #     Extract._validate! :undefined, to_opts, to_body
    #   end
    # end


    # def distill_float_to_undefined(ast, ctx,
    #  :float, from_opts, from_body, :undefined, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :float, :undefined, "float to undefined"
    #     Extract._validate! :float, from_opts, from_body
    #     Extract._validate! :undefined, to_opts, to_body
    #   end
    # end


    # def distill_number_to_undefined(ast, ctx,
    #  :number, from_opts, from_body, :undefined, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :number, :undefined, "number to undefined"
    #     Extract._validate! :number, from_opts, from_body
    #     Extract._validate! :undefined, to_opts, to_body
    #   end
    # end


    # def distill_string_to_undefined(ast, ctx,
    #  :string, from_opts, from_body, :undefined, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :string, :undefined, "string to undefined"
    #     Extract._validate! :string, from_opts, from_body
    #     Extract._validate! :undefined, to_opts, to_body
    #   end
    # end


    # def distill_binary_to_undefined(ast, ctx,
    #  :binary, from_opts, from_body, :undefined, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :binary, :undefined, "binary to undefined"
    #     Extract._validate! :binary, from_opts, from_body
    #     Extract._validate! :undefined, to_opts, to_body
    #   end
    # end


    # def distill_undefined_to_atom(ast, ctx,
    #  :undefined, from_opts, from_body, :atom, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :undefined, :atom, "undefined to atom"
    #     Extract._validate! :undefined, from_opts, from_body
    #     Extract._validate! :atom, to_opts, to_body
    #   end
    # end


    # def distill_undefined_to_boolean(ast, ctx,
    #  :undefined, from_opts, from_body, :boolean, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :undefined, :boolean, "undefined to boolean"
    #     Extract._validate! :undefined, from_opts, from_body
    #     Extract._validate! :boolean, to_opts, to_body
    #   end
    # end


    # def distill_undefined_to_integer(ast, ctx,
    #  :undefined, from_opts, from_body, :integer, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :undefined, :integer, "undefined to integer"
    #     Extract._validate! :undefined, from_opts, from_body
    #     Extract._validate! :integer, to_opts, to_body
    #   end
    # end


    # def distill_undefined_to_float(ast, ctx,
    #  :undefined, from_opts, from_body, :float, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :undefined, :float, "undefined to float"
    #     Extract._validate! :undefined, from_opts, from_body
    #     Extract._validate! :float, to_opts, to_body
    #   end
    # end


    # def distill_undefined_to_number(ast, ctx,
    #  :undefined, from_opts, from_body, :number, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :undefined, :number, "undefined to number"
    #     Extract._validate! :undefined, from_opts, from_body
    #     Extract._validate! :number, to_opts, to_body
    #   end
    # end


    # def distill_undefined_to_string(ast, ctx,
    #  :undefined, from_opts, from_body, :string, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :undefined, :string, "undefined to string"
    #     Extract._validate! :undefined, from_opts, from_body
    #     Extract._validate! :string, to_opts, to_body
    #   end
    # end


    # def distill_undefined_to_binary(ast, ctx,
    #  :undefined, from_opts, from_body, :binary, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :undefined, :binary, "undefined to binary"
    #     Extract._validate! :undefined, from_opts, from_body
    #     Extract._validate! :binary, to_opts, to_body
    #   end
    # end


    # def distill_boolean_to_atom(ast, ctx,
    #  :boolean, from_opts, from_body, :atom, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :boolean, :atom, "boolean to atom"
    #     Extract._validate! :boolean, from_opts, from_body
    #     Extract._validate! :atom, to_opts, to_body
    #   end
    # end


    # def distill_string_to_atom(ast, ctx,
    #  :string, from_opts, from_body, :atom, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :string, :atom, "string to atom"
    #     Extract._validate! :string, from_opts, from_body
    #     condition Meta.is_comptime? nil do
    #        distill_string_to_atom_comptime
    #      else
    #        distill_string_to_atom_runtime
    #     end
    #     Extract._validate! :atom, to_opts, to_body
    #   end
    # end


    # defp distill_string_to_atom_comptime(ast, ctx) do
    #   new_ast = try do
    #     String.to_existing_atom(ast)
    #   rescue
    #     ArgumentError -> Error.comptime(ctx, value_not_allowed(ast))
    #   end
    #   {new_ast, ctx}
    # end


    # defp distill_string_to_atom_runtime(ast, ctx) do
    #   {error_ast, [error_var]} = Error.runtime(ctx, value_not_allowed/1)
    #   new_ast = quote do
    #     value = unquote(error_var) = unquote(ast)
    #     try do
    #       String.to_existing_atom(value)
    #     rescue
    #       ArgumentError -> unquote(error_ast)
    #     end
    #   end
    #   {new_ast, Context.may_raise(ctx)}
    # end


    # def distill_atom_to_boolean(ast, ctx,
    #  :atom, from_opts, from_body, :boolean, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :atom, :boolean, "atom to boolean"
    #     Extract._validate! :boolean, from_opts, from_body
    #     condition Meta.is_comptime? nil do
    #        distill_atom_to_boolean_comptime
    #      else
    #        distill_atom_to_boolean_runtime
    #     end
    #     Extract._validate! :boolean, to_opts, to_body
    #   end
    # end


    # defp distill_atom_to_boolean_comptime(ast, ctx) do
    #   new_ast = case ast do
    #     true -> true
    #     false -> false
    #     value -> Error.comptime(ctx, distillation_error(value))
    #   end
    #   {new_ast, ctx}
    # end


    # defp distill_atom_to_boolean_runtime(ast, ctx) do
    #   {error_ast, [error_var]} = Error.runtime(ctx, distillation_error/1)
    #   new_ast = quote do
    #     case unquote(ast) do
    #       true -> true
    #       false -> false
    #       unquote(error_var) -> unquote(error_ast)
    #     end
    #   end
    #   {new_ast, Context.may_raise(ctx)}
    # end


    # def distill_string_to_boolean(ast, ctx,
    #  :string, from_opts, from_body, :boolean, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :string, :boolean, "string to boolean"
    #     Extract._validate! :string, from_opts, from_body
    #     condition Meta.is_comptime? nil do
    #        distill_string_to_boolean_comptime
    #      else
    #        distill_string_to_boolean_runtime
    #     end
    #     Extract._validate! :boolean, to_opts, to_body
    #   end
    # end


    # defp distill_string_to_boolean_comptime(ast, ctx) do
    #   new_ast = case ast do
    #     "true" -> true
    #     "false" -> false
    #     value -> Error.comptime(ctx, distillation_error(value))
    #   end
    #   {new_ast, ctx}
    # end


    # defp distill_string_to_boolean_runtime(ast, ctx) do
    #   {error_ast, [error_var]} = Error.runtime(ctx, distillation_error/1)
    #   new_ast = quote do
    #     case unquote(ast) do
    #       "true" -> true
    #       "false" -> false
    #       unquote(error_var) -> unquote(error_ast)
    #     end
    #   end
    #   {new_ast, Context.may_raise(ctx)}
    # end


    # def distill_float_to_integer(ast, ctx,
    #  :float, from_opts, from_body, :integer, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :float, :integer, "float to integer"
    #     Extract._validate! :float, from_opts, from_body
    #     condition Meta.is_comptime? nil do
    #        distill_float_to_integer_comptime
    #      else
    #        distill_float_to_integer_runtime
    #     end
    #     Extract._validate! :integer, to_opts, to_body
    #   end
    # end


    # defp distill_float_to_integer_comptime(ast, ctx) do
    #   new_ast = case ast do
    #     value when is_float(value) -> round(value)
    #     value -> Error.comptime(ctx, distillation_error(value))
    #   end
    #   {new_ast, ctx}
    # end


    # defp distill_float_to_integer_runtime(ast, ctx) do
    #   {error_ast, [error_var]} = Error.runtime(ctx, distillation_error/1)
    #   new_ast = quote do
    #     case unquote(ast) do
    #       value when is_float(value) -> round(value)
    #       unquote(error_var) -> unquote(error_ast)
    #     end
    #   end
    #   {new_ast, Context.may_raise(ctx)}
    # end


    # def distill_number_to_integer(ast, ctx,
    #  :number, from_opts, from_body, :integer, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :number, :integer, "number to integer"
    #     Extract._validate! :number, from_opts, from_body
    #     condition Meta.is_comptime? nil do
    #        distill_number_to_integer_comptime
    #      else
    #        distill_number_to_integer_runtime
    #     end
    #     Extract._validate! :integer, to_opts, to_body
    #   end
    # end


    # defp distill_number_to_integer_comptime(ast, ctx) do
    #   new_ast = case ast do
    #     value when is_integer(value) -> value
    #     value when is_float(value) -> round(value)
    #     value -> Error.comptime(ctx, distillation_error(value))
    #   end
    #   {new_ast, ctx}
    # end


    # defp distill_number_to_integer_runtime(ast, ctx) do
    #   {error_ast, [error_var]} = Error.runtime(ctx, distillation_error/1)
    #   new_ast = quote do
    #     case unquote(ast) do
    #       value when is_integer(value) -> value
    #       value when is_float(value) -> round(value)
    #       unquote(error_var) -> unquote(error_ast)
    #     end
    #   end
    #   {new_ast, Context.may_raise(ctx)}
    # end


    # def distill_integer_to_float(ast, ctx,
    #  :integer, from_opts, from_body, :float, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :integer, :float, "integer to float"
    #     Extract._validate! :integer, from_opts, from_body
    #     condition Meta.is_comptime? nil do
    #        distill_integer_to_float_comptime
    #      else
    #        distill_integer_to_float_runtime
    #     end
    #     Extract._validate! :float, to_opts, to_body
    #   end
    # end


    # defp distill_integer_to_float_comptime(ast, ctx) do
    #   new_ast = ast / 1
    #   {new_ast, ctx}
    # end


    # defp distill_integer_to_float_runtime(ast, ctx) do
    #   new_ast = quote do: unquote(ast) / 1
    #   {new_ast, ctx}
    # end


    # def distill_number_to_float(ast, ctx,
    #  :number, from_opts, from_body, :float, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :number, :float, "number to float"
    #     Extract._validate! :number, from_opts, from_body
    #     condition Meta.is_comptime? nil do
    #        distill_number_to_float_comptime
    #      else
    #        distill_number_to_float_runtime
    #     end
    #     Extract._validate! :float, to_opts, to_body
    #   end
    # end


    # defp distill_number_to_float_comptime(ast, ctx) do
    #   new_ast = case ast do
    #     value when is_integer(value) -> value / 1
    #     value when is_float(value) -> value
    #     value -> Error.comptime(ctx, distillation_error(value))
    #   end
    #   {new_ast, ctx}
    # end


    # defp distill_number_to_float_runtime(ast, ctx) do
    #   {error_ast, [error_var]} = Error.runtime(ctx, distillation_error/1)
    #   new_ast = quote do
    #     case unquote(ast) do
    #       value when is_integer(value) -> value / 1
    #       value when is_float(value) -> value
    #       unquote(error_var) -> unquote(error_ast)
    #     end
    #   end
    #   {new_ast, Context.may_raise(ctx)}
    # end


    # def distill_integer_to_number(ast, ctx,
    #  :integer, from_opts, from_body, :number, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :integer, :number, "integer to number"
    #     Extract._validate! :integer, from_opts, from_body
    #     Extract._validate! :number, to_opts, to_body
    #   end
    # end


    # def distill_float_to_number(ast, ctx,
    #  :float, from_opts, from_body, :number, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :float, :number, "float to number"
    #     Extract._validate! :float, from_opts, from_body
    #     Extract._validate! :number, to_opts, to_body
    #   end
    # end


    # def distill_atom_to_string(ast, ctx,
    #  :atom, from_opts, from_body, :string, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :atom, :string, "atom to string"
    #     Extract._validate! :atom, from_opts, from_body
    #     condition Meta.is_comptime? nil do
    #        distill_atombooleanfloatintegernumber_to_string_comptime
    #      else
    #        distill_atombooleanfloatintegernumber_to_string_runtime
    #     end
    #     Extract._validate! :string, to_opts, to_body
    #   end
    # end


    # def distill_boolean_to_string(ast, ctx,
    #  :boolean, from_opts, from_body, :string, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :boolean, :string, "boolean to string"
    #     Extract._validate! :boolean, from_opts, from_body
    #     condition Meta.is_comptime? nil do
    #        distill_atombooleanfloatintegernumber_to_string_comptime
    #      else
    #        distill_atombooleanfloatintegernumber_to_string_runtime
    #     end
    #     Extract._validate! :string, to_opts, to_body
    #   end
    # end


    # def distill_integer_to_string(ast, ctx,
    #  :integer, from_opts, from_body, :string, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :integer, :string, "integer to string"
    #     Extract._validate! :integer, from_opts, from_body
    #     condition Meta.is_comptime? nil do
    #        distill_atombooleanfloatintegernumber_to_string_comptime
    #      else
    #        distill_atombooleanfloatintegernumber_to_string_runtime
    #     end
    #     Extract._validate! :string, to_opts, to_body
    #   end
    # end


    # def distill_float_to_string(ast, ctx,
    #  :float, from_opts, from_body, :string, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :float, :string, "float to string"
    #     Extract._validate! :float, from_opts, from_body
    #     condition Meta.is_comptime? nil do
    #        distill_atombooleanfloatintegernumber_to_string_comptime
    #      else
    #        distill_atombooleanfloatintegernumber_to_string_runtime
    #     end
    #     Extract._validate! :string, to_opts, to_body
    #   end
    # end


    # def distill_number_to_string(ast, ctx,
    #  :number, from_opts, from_body, :string, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :number, :string, "number to string"
    #     Extract._validate! :number, from_opts, from_body
    #     condition Meta.is_comptime? nil do
    #        distill_atombooleanfloatintegernumber_to_string_comptime
    #      else
    #        distill_atombooleanfloatintegernumber_to_string_runtime
    #     end
    #     Extract._validate! :string, to_opts, to_body
    #   end
    # end


    # defp distill_atombooleanfloatintegernumber_to_string_comptime(ast, ctx) do
    #   new_ast = to_string(ast)
    #   {new_ast, ctx}
    # end


    # defp distill_atombooleanfloatintegernumber_to_string_runtime(ast, ctx) do
    #   new_ast = quote do: to_string(unquote(ast))
    #   {new_ast, ctx}
    # end


    # def distill_binary_to_string(ast, ctx,
    #  :binary, from_opts, from_body, :string, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :binary, :string, "binary to string"
    #     Extract._validate! :binary, from_opts, from_body
    #     Extract._validate! :string, to_opts, to_body
    #   end
    # end


    # def distill_string_to_binary(ast, ctx,
    #  :string, from_opts, from_body, :binary, to_opts, to_body) do
    #   pipeline ast, ctx do
    #     Meta.push_receipt :string, :binary, "string to binary"
    #     Extract._validate! :string, from_opts, from_body
    #     Extract._validate! :binary, to_opts, to_body
    #   end
    # end

  end


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