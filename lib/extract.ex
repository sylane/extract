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
  alias Extract.Meta.Options
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

    #FIXME: Remove this useless encapsulation.
    # It is required to prevent error 'ambiguous_catch_try_state'
    # with Erlang versions < 18.
    quote do: fn -> unquote(_ast) end.()
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

    #FIXME: Remove this useless encapsulation.
    # It is required to prevent error 'ambiguous_catch_try_state'
    # with Erlang versions < 18.
    quote do: fn -> unquote(_ast) end.()
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
    from_opts = Options.to2from(__CALLER__, opts)
    _ast = pipeline value, env: __ENV__, caller: __CALLER__ do
      _meta_distill! from, from_opts, [], to, opts, body, receipts
      Meta.terminate!
    rescue
      Meta.comptime_rescue!
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)

    #FIXME: Remove this useless encapsulation.
    # It is required to prevent error 'ambiguous_catch_try_state'
    # with Erlang versions < 18.
    quote do: fn -> unquote(_ast) end.()
  end


  defmacro distill(value, from, to, opts \\ [], body \\ []) do
    module = Mode.module(__CALLER__)
    receipts = Receipts.all(module)
    from_opts = Options.to2from(__CALLER__, opts)
    _ast = pipeline value, env: __ENV__, caller: __CALLER__ do
      _meta_distill! from, from_opts, [], to, opts, body, receipts
      Meta.terminate
    rescue
      Meta.comptime_rescue
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)

    #FIXME: Remove this useless encapsulation.
    # It is required to prevent error 'ambiguous_catch_try_state'
    # with Erlang versions < 18.
    quote do: fn -> unquote(_ast) end.()
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
      Extract.Meta.CodeGen.list_functions()
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
   from, fopts, fbody, to, topts, tbody, receipts) do
    otherwise = try do
      {:ok, Meta.bad_receipt_error(nil, ctx, from, to)}
    rescue
      e in Extract.Error -> {:error, {e, System.stacktrace()}}
    end
    case {from, to} do
      {f, t} when is_atom(from) and is_atom(to) ->
        case get_receipts(receipts, f, t) do
          [] -> Meta.bad_receipt_error(nil, ctx, from, to)
          [receipt] ->
            case  gen_choice(receipt, ast, ctx, fopts, fbody, topts, tbody) do
              {:error, {e, s}} -> reraise e, s
              {:ok, result} -> result
            end
        end
      {f, t} when is_atom(f) ->
        choices = for r <- get_receipts(receipts, f, :any) do
          {r.to, gen_choice(r, ast, ctx, fopts, fbody, topts, tbody)}
        end
        Extract.Pipeline.select(ctx, t, choices, otherwise)
      {f, t} when is_atom(t) ->
        choices = for r <- get_receipts(receipts, :any, t) do
          {r.from, gen_choice(r, ast, ctx, fopts, fbody, topts, tbody)}
        end
        Extract.Pipeline.select(ctx, f, choices, otherwise)
      {f, t} ->
        choices = for r <- receipts do
          {{r.from, r.to}, gen_choice(r, ast, ctx, fopts, fbody, topts, tbody)}
        end
        Extract.Pipeline.select(ctx, {f, t}, choices, otherwise)
    end
  end


  defp get_receipts(receipts, f, t), do: get_receipts(receipts, f, t, [])


  defp get_receipts([], _, _, acc), do: acc

  defp get_receipts([r | receipts], :any, :any, acc) do
    get_receipts(receipts, :any, :any, [r | acc])
  end

  defp get_receipts([%Receipts{from: f} = r | receipts], f, :any, acc) do
    get_receipts(receipts, f, :any, [r | acc])
  end

  defp get_receipts([%Receipts{to: t} = r | receipts], :any, t, acc) do
    get_receipts(receipts, :any, t, [r | acc])
  end

  defp get_receipts([%Receipts{from: f, to: t} = r | receipts], f, t, acc) do
    get_receipts(receipts, f, t, [r | acc])
  end

  defp get_receipts([_ | receipts], f, t, acc) do
    get_receipts(receipts, f, t, acc)
  end


  defp gen_choice(r, v, ctx, fopts, fbody, topts, tbody) do
    try do
      args = [v, ctx, r.from, fopts, fbody, r.to, topts, tbody]
      {:ok, Receipts.comptime(r, args)}
    rescue
      e in Extract.Error -> {:error, {e, System.stacktrace()}}
    end
  end

end
