defmodule Proto.Commit do

  # use Extract
  # use Proto.Types
  # use Proto.Commit.Changeset

  defstruct [:id, :author, msg: nil, docs: []]

  # extract :struct do
  #   "commit" :: struct Commit do
  #     "identifier" ::  :id      |>  spatch_id
  #     "author"     ::  :author  |>  user_id
  #     "message"    ::  :msg     |>  string optional: true
  #     "document"   ::  :docs    |>  list delegate(Changeset)
  #   end
  # end

  # extract :term do
  #   "commit" :: map do
  #     "identifier" ::  :cid        |>  spatch_id
  #     "author"     ::  :author     |>  user_id
  #     "message"    ::  :message    |>  string optional: true
  #     "document"   ::  :documents  |>  list delegate(Changeset)
  #   end
  # end

  # extract :poison do
  #   "commit" :: map do
  #     "identifier" ::  "cid"       |>  string
  #     "author"     ::  "author"    |>  string
  #     "message"    ::  "message"   |>  string optional: true
  #     "document"   ::  "document"  |>  list delegate(Changeset)
  #   end
  # end
end
