defmodule Extract.Meta do

  require Extract.Meta.Context

  alias Extract.Meta.Context


  def branch(context, format, kv) when is_atom(format) do
    context = Context.merge(context, (for {_, {_, c}} <- kv, do: c))
    case Keyword.fetch(kv, format) do
      {:ok, {ast, _}} -> {ast, context}
      :error ->
        raise Extract.FormatError,
          message: "format #{format} is not supported",
          reason: {:format_not_supported, format}
    end
  end

  def branch(context, format, kv) do
    context = Context.merge(context, (for {_, {_, c}} <- kv, do: c))
    choices_ast = for {k, {ast, _}} <- kv do
      [choice_ast] = quote do
        unquote(k) -> unquote(ast)
      end
      choice_ast
    end
    default_ast = quote do
      other ->
          raise Extract.FormatError,
            message: "format #{inspect unquote(format)} is not supported",
            reason: {:format_not_supported, unquote(format)}
    end
    all_choices_ast = choices_ast ++ default_ast
    ast = quote do
      case unquote(format) do
        unquote(all_choices_ast)
      end
    end
    {ast, context}
  end

end