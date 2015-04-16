defmodule Extract.Meta.Options do

  require Extract.Meta.Error

  alias Extract.Meta.Context
  alias Extract.Meta.Error


  def validate(ctx, opts, allowed) do
    _validate(ctx, resolve(ctx, opts), allowed)
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


  defp _validate(_ctx, [], _allowed), do: :ok

  defp _validate(ctx, [{name, quoted} | opts], allowed)
   when is_atom(name) and is_list(allowed) do
    value = resolve(ctx, quoted, name)
    case valid?(name, value) do
      false ->
        {:error, {{:bad_option, {name, value}},
                  "invalid option #{name}: #{inspect value}"}}
      true ->
        case Enum.member?(allowed, name) do
          true -> _validate(ctx, opts, allowed)
          false ->
            {:error, {{:option_not_allowed, name},
                      "option #{name} is not allowed"}}
        end
    end
  end

  defp valid?(:optional, flag) when is_boolean(flag), do: true
  defp valid?(:allow_undefined, flag) when is_boolean(flag), do: true
  defp valid?(:allow_missing, flag) when is_boolean(flag), do: true
  defp valid?(:allowed, list) when is_list(list), do: true
  defp valid?(:allowed, map) when is_map(map), do: true
  defp valid?(:default, _any), do: true
  defp valid?(:max, num) when is_number(num), do: true
  defp valid?(:min, num) when is_number(num), do: true
  defp valid?(_other, _any), do: false


  defp get_option(ctx, opts, key, default) do
    case Keyword.fetch(resolve(ctx, opts), key) do
      {:ok, quoted} -> resolve(ctx, quoted, key)
      :error -> default
    end
  end


  defp fetch_option(ctx, opts, key) do
    case Keyword.fetch(resolve(ctx, opts), key) do
      {:ok, quoted} -> {:ok, resolve(ctx, quoted, key)}
      :error -> :error
    end
  end


  defp resolve(ctx, quoted, key \\ nil)

  defp resolve(ctx, {:@, _, _} = quoted, key) do
    try do
      {value, []} = Context.eval_quoted(ctx, quoted)
      value
    rescue
      [MatchError, CompileError] ->
        if key == nil do
          Error.comptime(ctx, error(:bad_options,
            "invalid compile-time options: #{inspect quoted}"))
        else
          Error.comptime(ctx, error({:bad_option, key},
            "invalid compile-time option #{key}: #{inspect quoted}"))
        end
    end
  end

  defp resolve(_ctx, value, _key), do: value

end