defmodule Extract.Util do

  require Extract.Meta.Context

  alias Extract.Meta.Context


  def identity(ast, ctx), do: {ast, ctx}


  def debug(ast, ctx, kv \\ []) do
    Context.debug(ast, ctx, kv)
    {ast, ctx}
  end

end