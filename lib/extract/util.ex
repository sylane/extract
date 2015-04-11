defmodule Extract.Util do

  require Extract.Meta.Context
  require Extract.Meta.Debug

  alias Extract.Meta.Context
  alias Extract.Meta.Debug


  def identity(ast, ctx), do: {ast, ctx}


  def debug(ast, ctx, kv \\ []) do
    case Keyword.has_key?(kv, :info) do
      true -> {Debug.ast(ast, kv), ctx}
      false ->
        debug_info = Context.debug(ctx)
        {Debug.ast(ast, [{:info, debug_info} | kv]), ctx}
    end
  end

end