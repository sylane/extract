defmodule Extract.Meta.Options do

  require Extract.Meta.Error
  require Extract.Meta.Ast

  alias Extract.Meta.Context
  alias Extract.Meta.Error


  def validate(ctx, opts, allowed) do
    _validate(ctx, resolve(ctx, opts), allowed)
  end


  def get(ctx, opts, key, default \\ nil) do
    case fetch(ctx, opts, key) do
      :error -> default
      {:ok, value} -> value
    end
  end


  def fetch(ctx, opts, allow_opt)
   when allow_opt in [:allow_undefined, :allow_missing] do
    case fetch_option(ctx, opts, :optional) do
      :error -> fetch_option(ctx, opts, allow_opt)
      {:ok, false} -> fetch_option(ctx, opts, allow_opt)
      {:ok, true} = result -> result
      {:ok, ast1} ->
        case fetch_option(ctx, opts, allow_opt) do
          :error -> {:ok, ast1}
          {:ok, false} -> {:ok, ast1}
          {:ok, true} = result -> result
          {:ok, ast2} -> {:ok, quote do: unquote(ast1) or unquote(ast2)}
        end
    end
  end

  def fetch(ctx, opts, key) do
    fetch_option(ctx, opts, key)
  end


  defp allowed?(allowed, :allow_undefined) do
    Enum.member?(allowed, :optional) or Enum.member?(allowed, :allow_undefined)
  end

  defp allowed?(allowed, :allow_missing) do
    Enum.member?(allowed, :optional) or Enum.member?(allowed, :allow_missing)
  end

  defp allowed?(allowed, name) do
    Enum.member?(allowed, name)
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
        case allowed?(allowed, name) do
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
  defp valid?(:optional, {var, _, ns})
   when is_atom(var) and is_atom(ns), do: true
  defp valid?(:allow_undefined, {var, _, ns})
   when is_atom(var) and is_atom(ns), do: true
  defp valid?(:allow_missing, {var, _, ns})
   when is_atom(var) and is_atom(ns), do: true
  defp valid?(:allowed, {var, _, ns})
   when is_atom(var) and is_atom(ns), do: true
  defp valid?(:max, {var, _, ns})
   when is_atom(var) and is_atom(ns), do: true
  defp valid?(:min, {var, _, ns})
   when is_atom(var) and is_atom(ns), do: true
  defp valid?(_other, _any), do: false


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