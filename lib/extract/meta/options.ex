defmodule Extract.Meta.Options do


  def validate([], _allowed), do: :ok

  def validate([{name, _} = opt | opts], allowed)
   when is_atom(name) and is_list(allowed) do
    case valid?(opt) do
      false ->
        {:error, {{:bad_option, opt},
                  "invalid option: #{inspect opt}"}}
      true ->
        case Enum.member?(allowed, name) do
          true -> validate(opts, allowed)
          false ->
            {:error, {{:option_not_allowed, name},
                      "option #{name} is not allowed"}}
        end
    end
  end


  def allow_undefined(opts) do
    Keyword.get(opts, :optional, false) or Keyword.get(opts, :undefined, false)
  end


  def allow_missing(opts) do
    Keyword.get(opts, :optional, false) or Keyword.get(opts, :missing, false)
  end


  def default(opts) do
    case Keyword.fetch(opts, :default) do
      :error -> nil
      result -> result
    end
  end


  defp valid?({:optional, flag}) when is_boolean(flag), do: true
  defp valid?({:allow_undefined, flag}) when is_boolean(flag), do: true
  defp valid?({:allow_missing, flag}) when is_boolean(flag), do: true
  defp valid?({:default, _any}), do: true
  defp valid?(_other), do: false

end