defmodule Proto.Commit.Changeset do

  # use Extract
  # use Proto.Types

  defstruct [:id, :ver, ctx: nil, acl: nil, data: nil, ops: nil]

  # extract :struct do
  #   "changeset" :: struct Changeset do
  #     "document identifier" ::
  #                      :id   |>  spatch_id
  #     "version"    ::  :ver  |>  integer min: 1, max: 9007199254740991
  #     "context"    ::  :ctx  |>  undefined optional: true
  #     "acl"        ::  :acl  |>  list(user_id(), optional: true)
  #     "data"       ::  :data |>  any optional: true
  #     "operations" ::  :ops  |>  undefined optional: true
  #   end
  # end

  # extract :term do
  #   "changeset" :: map do
  #     "document identifier" ::
  #                      :did       |>  spatch_id
  #     "version"    ::  :version   |>  integer min: 1, max: 9007199254740991
  #     "context"    ::  :context   |>  undefined optional: true
  #     "acl"        ::  :acl       |>  list optional: true, do: user_id
  #     "data"       ::  :data      |>  any optional: true
  #     "operations" ::  :oprations |>  undefined optional: true
  #   end
  # end

  # extract Changeset, for: :poison do
  #   "changeset" :: map do
  #     "document identifier" ::
  #                      "did"       |>  string
  #     "version"    ::  "version"   |>  integer min: 1, max: 9007199254740991
  #     "context"    ::  "context"   |>  undefined optional: true
  #     "acl"        ::  "acl"       |>  list(string(), optional: true)
  #     "data"       ::  "data"      |>  any optional: true
  #     "operations" ::  "oprations" |>  undefined optional: true
  #   end
  # end
end
