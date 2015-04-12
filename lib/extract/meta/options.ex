defmodule Extract.Meta.Options do

  require Extract.Meta.Error

  alias Extract.Meta.Context
  alias Extract.Meta.Error


  def validate(_ctx, [], _allowed), do: :ok

  def validate(ctx, [{name, quoted} | opts], allowed)
   when is_atom(name) and is_list(allowed) do
    value = resolve(ctx, name, quoted)
    case valid?(name, value) do
      false ->
        {:error, {{:bad_option, {name, value}},
                  "invalid option #{name}: #{inspect value}"}}
      true ->
        case Enum.member?(allowed, name) do
          true -> validate(ctx, opts, allowed)
          false ->
            {:error, {{:option_not_allowed, name},
                      "option #{name} is not allowed"}}
        end
    end
  end


  def get(ctx, opts, key, default \\ nil)

  def get(ctx, opts, :allow_missing, default) do
    optional = get_option(ctx, opts, :optional, false)
    allow_missing = get_option(ctx, opts, :allow_missing, false)
    optional or allow_missing or default
  end

  def get(ctx, opts, :allow_undefined, default) do
    optional = get_option(ctx, opts, :optional, false)
    allow_undefined = get_option(ctx, opts, :allow_undefined, false)
    optional or allow_undefined or default
  end

  def get(ctx, opts, key, default) do
    get_option(ctx, opts, key, default)
  end


  def fetch(ctx, opts, :allow_missing) do
    case fetch_option(ctx, opts, :optional) do
      :error -> fetch_option(ctx, opts, :allow_missing)
      result -> result
    end
  end

  def fetch(ctx, opts, :allow_undefined) do
    case fetch_option(ctx, opts, :optional) do
      :error -> fetch_option(ctx, opts, :allow_undefined)
      result -> result
    end
  end

  def fetch(ctx, opts, key) do
    fetch_option(ctx, opts, key)
  end


  defp valid?(:optional, flag) when is_boolean(flag), do: true
  defp valid?(:allow_undefined, flag) when is_boolean(flag), do: true
  defp valid?(:allow_missing, flag) when is_boolean(flag), do: true
  defp valid?(:allowed, list) when is_list(list), do: true
  defp valid?(:allowed, map) when is_map(map), do: true
  defp valid?(:default, _any), do: true
  defp valid?(:max, num) when is_integer(num), do: true
  defp valid?(:min, num) when is_integer(num), do: true
  defp valid?(_other, _any), do: false


  defp get_option(ctx, opts, key, default) do
    case Keyword.fetch(opts, key) do
      {:ok, quoted} -> resolve(ctx, key, quoted)
      :error -> default
    end
  end


  defp fetch_option(ctx, opts, key) do
    case Keyword.fetch(opts, key) do
      {:ok, quoted} -> {:ok, resolve(ctx, key, quoted)}
      :error -> :error
    end
  end


  defp resolve(ctx, key, {:@, _, _} = quoted) do
    try do
      {value, []} = Context.eval_quoted(ctx, quoted)
      value
    rescue
      [MatchError, CompileError] ->
        Error.comptime(ctx, error({:bad_option, key},
          "invalid compile-time option #{key}: #{inspect quoted}"))
    end
  end

  defp resolve(_ctx, _key, value), do: value

end