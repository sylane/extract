defmodule Proto.Request.Push do

  use Extract
  use Proto.Commit

  # extract [:struct, :term, :poison], do: delegate Commit
end
