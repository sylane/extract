defmodule Extract.Types do

  use Extract.Pipeline

  alias Extract.Types
  alias Extract.Meta
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
        branch format do
          :undefined -> validate_dummy opts
          :atom      -> validate_dummy opts
          :boolean   -> validate_dummy opts
          :integer   -> validate_integer opts
          :float     -> validate_dummy opts
          :string    -> validate_dummy opts
          :binary    -> validate_dummy opts
          :list      -> validate_dummy opts
          :tuple     -> validate_dummy opts
          :map       -> validate_dummy opts
          :struct    -> validate_dummy opts
        end
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


  defp validate_dummy(ast, ctx, _opts) do
    pipeline ast, ctx do
      Util.identity
    end
  end


  defp validate_integer(ast, ctx, opts) do
    pipeline ast, ctx do
      Meta.type_info(:integer, "integer")
      Meta.allowed_options opts,
        [:optional, :allow_undefined, :allow_missing, :default]
      condition Meta.defined? opts do
        add_something 3
      else
        Types.do_undefined
      end
    end
  end


  def do_undefined(ast, ctx) do
    ast = quote do
      "undefined: #{inspect unquote(ast)}"
    end
    {ast, ctx}
  end

  def add_something(ast, ctx, number) do
    ast = quote do
      unquote(ast) + unquote(number)
    end
    {ast, ctx}
  end

end