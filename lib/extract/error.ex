defmodule Extract.Error do

  defexception [:message, :reason, stash: []]

  def exception(kv) do
    reason = Keyword.fetch!(kv, :reason)
    message = Keyword.fetch!(kv, :message)
    %Extract.Error{message: message, reason: reason}
  end

end
