defmodule Extract.Error do

  defexception [:message, :reason]

  def exception(kv) do
    reason = Keyword.get(kv, :reason, :unknown)
    message = Keyword.get(kv, :message, "extract error")
    %Extract.Error{message: message, reason: reason}
  end

end
