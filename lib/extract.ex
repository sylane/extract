defmodule Extract do

  use Extract.Pipeline

  require Extract.Meta
  require Extract.Meta.Ast
  require Extract.Meta.CodeGen
  require Extract.Meta.Context
  require Extract.Meta.Debug
  require Extract.Meta.Error
  require Extract.Meta.Extracts
  require Extract.Meta.Receipts
  require Extract.Meta.Mode
  require Extract.Meta.Options
  require Extract.Util
  require Extract.Valid
  require Extract.Trans
  require Extract.Error

  alias Extract.Meta
  alias Extract.Meta.Extracts
  alias Extract.Meta.Receipts
  alias Extract.Meta.Mode
  alias Extract.Meta.Error


  defmacro validate!(value, format, opts \\ [], body \\ []) do
    module = Mode.module(__CALLER__)
    extracts = Extracts.all(module)
    _ast = pipeline value, env: __ENV__, caller: __CALLER__ do
      _meta_validate! format, opts, body, extracts
      Meta.terminate!
    rescue
      Meta.comptime_rescue!
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro validate(value, format, opts \\ [], body \\ []) do
    module = Mode.module(__CALLER__)
    extracts = Extracts.all(module)
    _ast = pipeline value, env: __ENV__, caller: __CALLER__ do
      _meta_validate! format, opts, body, extracts
      Meta.terminate
    rescue
      Meta.comptime_rescue
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro _validate!(ast, ctx, fmt, opts, body) when is_atom(fmt) do
    module = Mode.module(__CALLER__, :defining)
    case Extracts.fetch(module, fmt) do
      :error -> Error.comptime_bad_format(fmt)
      {:ok, extract} ->
        Extracts.runtime(extract, [ast, ctx, fmt, opts, body])
    end
  end


defmacro distill!(value, from, to, opts \\ [], body \\ []) do
    module = Mode.module(__CALLER__)
    receipts = Receipts.all(module)
    _ast = pipeline value, env: __ENV__, caller: __CALLER__ do
      _meta_distill! from, [], [], to, opts, body, receipts
      Meta.terminate!
    rescue
      Meta.comptime_rescue!
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro distill(value, from, to, opts \\ [], body \\ []) do
    module = Mode.module(__CALLER__)
    receipts = Receipts.all(module)
    _ast = pipeline value, env: __ENV__, caller: __CALLER__ do
      _meta_distill! from, [], [], to, opts, body, receipts
      Meta.terminate
    rescue
      Meta.comptime_rescue
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro _distill!(ast, ctx, from, from_opts, from_body, to, to_opts, to_body)
   when is_atom(from) and is_atom(to) do
    module = Mode.module(__CALLER__)
    case Receipts.fetch(module, from, to) do
      :error -> Error.comptime_bad_receipt_error(from, to)
      {:ok, receipt} ->
        args = [ast, ctx, from, from_opts, from_body, to, to_opts, to_body]
        Receipts.runtime(receipt, args)
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
        {x.name, {:ok, Extracts.comptime(x, [ast, ctx, x.name, opts, body])}}
      rescue
        e in Extract.Error ->
          {x.name, {:error, {e, System.stacktrace()}}}
      end
    end
    Extract.Pipeline.select(ctx, fmt, choices, otherwise)
  end


  defp _meta_distill!(ast, ctx,
   from, from_opts, from_body, to, to_opts, to_body, receipts) do
    otherwise = try do
      {:ok, Meta.bad_receipt_error(nil, ctx, from, to)}
    rescue
      e in Extract.Error -> {:error, {e, System.stacktrace()}}
    end
    choices = for r <- receipts do
      key = {r.from, r.to}
      try do
        args = [ast, ctx, r.from, from_opts, from_body, r.to, to_opts, to_body]
        {key, {:ok, Receipts.comptime(r, args)}}
      rescue
        e in Extract.Error ->
          {key, {:error, {e, System.stacktrace()}}}
      end
    end
    Extract.Pipeline.select(ctx, {from, to}, choices, otherwise)
  end

end
