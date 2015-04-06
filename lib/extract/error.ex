defmodule Extract.Error do

  defexception [:message, :reason, :context, stash: []]

  def exception(kv) do
    context = Keyword.fetch!(kv, :context)
    reason = Keyword.fetch!(kv, :reason)
    message = Keyword.fetch!(kv, :message)
    %Extract.Error{message: message, reason: reason, context: context}
  end

  defmacro format_not_supported(format, _context) do
    quote do
      raise FormatError,
        message: "format #{unquote(format)} is not supported",
        reason: {format_not_supported, unquote(format)}
    end
  end

end
