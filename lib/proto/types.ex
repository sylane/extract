defmodule Proto.Types do

  use Extract

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


  defmacro condence(value, from, to, opts \\ []) do
    context = Extract.Context.new()
    quote do
      try do
        # What about :undefined and :missing ?
        {:ok, _condence(unquote(value), unquote(from), unquote(to),
                        unquote(context), unquote(opts))}
      rescue
        e in ExtractError -> {:error, e.reason}
      end
    end
  end


  defmacro condence!(value, from, to, opts \\ []) do
    context = Extract.Context.new()
    quote do
      # What about :undefined and :missing ?
      _condence(unquote(value), unquote(from), unquote(to),
                unquote(context), unquote(opts))
    end
  end


  defmacro validate(value, format, opts \\ []) do
    context = Extract.Context.new()
    quote do
      try do
        # What about :undefined and :missing ?
        _validate(unquote(value), unquote(format),
                  unquote(context), unquote(opts))
      rescue
        e in ExtractError -> {:error, e.reason}
      end
    end
  end


  defmacro validate!(value, format, opts \\ []) do
    context = Extract.Context.new()
    quote do
      # What about :undefined and :missing ?
      _validate(unquote(value), unquote(format),
                unquote(context), unquote(opts))
    end
  end


  defmacro _types(), do: [:spatch_id, :user_id]


  defmacro _validate(_value, :spatch_id, context, _opts) do
    _context = Extract.Context.push(context, "spatch identifier")
    quote do
    end
  end

  defmacro _validate(_value, :user_id, context, _opts) do
    _context = Extract.Context.push(context, "user identifier")
    quote do
    end
  end

  defmacro _validate(__value, format, context, _opts) do
    raise Extract.Error,
      message: "unsuported format #{format}",
      context: context
  end


  # defmacro _condence(value, :string, :spatch_id, context, opts) do
  #   unquote bind_quoted: [value: value, context: context, opts: opts] do
  #     value
  #     |> Extract.Meta.validate(:string, context, opts)
  #     |> Transform.regex(@rx_spatch_id, capture: :all_but_first, as: :tuple
  #     |>
  # end
  # defmacro _condence(_value, :spatch_id, :string, _context, _opts) do
  # defmacro _condence(_value, :tuple, :spatch_id, _context, _opts) do
  # defmacro _condence(_value, :spatch_id, :tuple, _context, _opts) do
  # defmacro _condence(_value, :string, :user_id, _context, _opts) do
  # defmacro _condence(_value, :user_id, :string, _context, _opts) do
  # defmacro _condence(_value, :tuple, :user_id, _context, _opts) do
  # defmacro _condence(_value, from, to, _context, _opts) when is_atom(from) and is_atom(to) do
  # defmacro _condence(_value, from, :spatch_id, _context, _opts) do
  # defmacro _condence(_value, from, :string, _context, _opts) do
  # defmacro _condence(_value, from, :spatch_id, _context, _opts) do
  # defmacro _condence(_value, from, :tuple, _context, _opts) do
  # defmacro _condence(_value, from, :user_id, _context, _opts) do
  # defmacro _condence(_value, from, :string, _context, _opts) do
  # defmacro _condence(_value, from, :user_id, _context, _opts) do
  # defmacro _condence(_value, from, to, _context, _opts) when is_atom(to) do
  # defmacro _condence(_value, :string, to, _context, _opts) do
  # defmacro _condence(_value, :spatch_id, to, _context, _opts) do
  # defmacro _condence(_value, :tuple, to, _context, _opts) do
  # defmacro _condence(_value, :spatch_id, to, _context, _opts) do
  # defmacro _condence(_value, :string, to, _context, _opts) do
  # defmacro _condence(_value, :user_id, to, _context, _opts) do
  # defmacro _condence(_value, :tuple, to, _context, _opts) do
  # defmacro _condence(_value, from, to, _context, _opts) when is_atom(from) do
  # defmacro _condence(_value, from, to, _context, _opts) do



  # defmacro _condence(_value, :string, :spatch_id, _context, _opts) do
  #   quote do
  #   end
  # end

  # defmacro _condence(_value, :spatch_id, :string, _context, _opts) do
  #   quote do
  #   end
  # end

  # defmacro _condence(_value, :tuple, :spatch_id, _context, _opts) do
  #   quote do
  #   end
  # end

  # defmacro _condence(_value, :spatch_id, :tuple, _context, _opts) do
  #   quote do
  #   end
  # end

  # defmacro _condence(_value, :string, :user_id, _context, _opts) do
  #   quote do
  #   end
  # end

  # defmacro _condence(_value, :user_id, :string, _context, _opts) do
  #   quote do
  #   end
  # end

  # defmacro _condence(_value, :tuple, :user_id, _context, _opts) do
  #   quote do
  #   end
  # end

  # defmacro _condence(_value, :user_id, :tuple, _context, _opts) do
  #   quote do
  #   end
  # end

end
