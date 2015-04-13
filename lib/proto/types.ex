defmodule Proto.Types do

  # use Extract

  @rx_user_name ~r"^[a-zA-Z][a-zA-Z0-9.]*[a-zA-Z0-9]$"
  @rx_domain_id ~r"^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9](?:\.[a-zA-Z]+)?$"
  @rx_unique_id ~r"^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$"
  @rx_spatch_id ~r"^([a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9](?:\.[a-zA-Z]+)?)/([a-zA-Z][a-zA-Z0-9.]*[a-zA-Z0-9])/([a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9])$"


  # extract :spatch_id do
  #   "spatch ientifier" :: tuple do
  #       string(regex: @rx_domain_id)
  #       string(regex: @rx_user_id)
  #       string(regex: @rx_unique_id)
  #     end
  # end

  # extract :user_id do
  #   "user ientifier" :: tuple do
  #       string(regex: @rx_user_id)
  #       string(regex: @rx_domain_id)
  #     end
  # end

  # condence (:string -> :spatch_id) do
  #   Transform.regex @rx_spatch_id, capture: :all_but_first, as: :tuple
  # end

  # condence (:spatch_id -> :string) do
  #   Transform.tuple_to_list |> Transform.join "/"
  # end

  # condence (:spatch_id <> :tuple), do: Transform.identity

  # condence (:string -> :user_id) do
  #   Transform.regex @rx_user_id, capture: :all_but_first, as: :tuple
  # end

  # condence (:user_id -> :string) do
  #   Transform.tuple_to_list |> Transform.join "@"
  # end

  # condence (:user_id <> :tuple), do: Transform.identity


end
