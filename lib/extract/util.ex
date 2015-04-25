defmodule Extract.Util do

  require Extract.Meta.Context

  alias Extract.Meta.Context


  def identity(ast, ctx), do: {ast, ctx}


  def debug(ast, ctx, kv \\ []) do
    Context.debug(ast, ctx, kv)
    {ast, ctx}
  end


  def trace(ast, ctx, str) do
    IO.puts str
    {ast, ctx}
  end

  def trace_context(ast, ctx, prefix \\ nil) do
    props = Context.properties(ctx)
    format = Context.current_format(ctx)
    raise? = Context.may_raise?(ctx)
    missing? = Context.may_be_missing?(ctx)
    undefined? = Context.may_be_undefined?(ctx)
    receipts = Keyword.get(props, :receipt_history, [])
    extracts = Keyword.get(props, :extract_history, [])
    lastr = safe_hd(receipts, nil)
    lastx = safe_hd(extracts, nil)
    prefix = if prefix == nil, do: "Context", else: prefix
    msg = "#{prefix}: format=#{inspect format}, raise?=#{raise?}, "
       <> "undefined?=#{undefined?}, missing?=#{missing?}, "
       <> "last_extract=#{inspect lastx}, last_receipt=#{inspect lastr}"
    IO.puts msg
    {ast, ctx}
  end



  defp safe_hd([{k, _} |_], _), do: k
  defp safe_hd(_, default), do: default

end