defmodule Extract do

  use Extract.Pipeline

  require Extract.Meta
  require Extract.Meta.Ast
  require Extract.Meta.CodeGen
  require Extract.Meta.Context
  require Extract.Meta.Debug
  require Extract.Meta.Error
  require Extract.Meta.Extracts
  require Extract.Meta.Mode
  require Extract.Meta.Options
  require Extract.Util
  require Extract.Valid
  require Extract.Trans
  require Extract.Error

  alias Extract.Meta
  alias Extract.Meta.Ast
  alias Extract.Meta.Extracts


  defmacro validate!(value, format, opts \\ [], body \\ []) do
    #FIXME: handle context errors (call from non-managed modules)
    extracts = Extracts.all(__CALLER__.module)
    _ast = pipeline value, env: __ENV__, caller: __CALLER__ do
      _meta_validate! format, opts, body, extracts
      Meta.terminate!
    rescue
      Meta.comptime_rescue!
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro validate(value, format, opts \\ [], body \\ []) do
    #FIXME: handle context errors (call from non-managed modules)
    extracts = Extracts.all(__CALLER__.module)
    _ast = pipeline value, env: __ENV__, caller: __CALLER__ do
      _meta_validate! format, opts, body, extracts
      Meta.terminate
    rescue
      Meta.comptime_rescue
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro _validate!(ast, ctx, fmt, opts, body) when is_atom(fmt) do
    #FIXME: handle context errors (call from non-managed modules)
    case Extracts.fetch(__CALLER__.module, fmt) do
      :error -> Meta.bad_format_error(fmt)
      {:ok, extract} ->
        Ast.call(extract.mod, extract.fun, [ast, ctx, opts, body])
    end
  end


  defmacro __using__(_) do
    _ast = quote do
      require Extract.Meta.Mode
      Extract.Meta.Mode.start_defining()
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro __before_compile__(_env) do
    _ast = quote do
      require Extract.Meta.CodeGen
      Extract.Meta.CodeGen.using_macro()
      Extract.Meta.CodeGen.validation_functions()
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defp _meta_validate!(ast, ctx, fmt, opts, body, extracts) do
    otherwise = try do
      {:ok, Meta.bad_format_error(nil, ctx, fmt)}
    rescue
      e in Extract.Error -> {:error, {e, System.stacktrace()}}
    end
    choices = for x <- extracts do
      try do
        {x.name, {:ok, Extracts.call(x, ast, ctx, opts, body)}}
      rescue
        e in Extract.Error ->
          {x.name, {:error, {e, System.stacktrace()}}}
      end
    end
    Extract.Pipeline.select(ctx, fmt, choices, otherwise)
  end

end
