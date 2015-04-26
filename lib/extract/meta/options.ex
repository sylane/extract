defmodule Extract.Meta.Options do

  require Extract.Meta.Error
  require Extract.Meta.Ast

  alias Extract.Meta.Context
  alias Extract.Meta.Error


  def validate!(ctx, opts, allowed) do
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


  def to2from(ctx_or_env, opts) do
    # Deduce the distillation options for the source extract given the options
    # of the target extract. e.g. If the target extract have a default value,
    # the source must be optional
    take_options(ctx_or_env, resolve(ctx_or_env, opts, "options"),
                [:optional, :allow_undefined, :allow_missing])
  end


  defp take_options(ctx_or_env, kv, opts) do
    take_options(ctx_or_env, kv, opts, [])
  end


  defp take_options(_ctx_or_env, _kv, [], acc), do: acc

  defp take_options(ctx_or_env, kv, [:optional | opts], acc) do
    case Keyword.fetch(kv, :optional) do
      {:ok, value} ->
        case resolve(ctx_or_env, value, :optional) do
          true -> take_options(ctx_or_env, kv, opts, [{:optional, true} | acc])
          false ->
            case Keyword.fetch(kv, :default) do
              :error ->
                take_options(ctx_or_env, kv, opts, [{:optional, false} | acc])
              {:ok, _any} ->
                take_options(ctx_or_env, kv, opts, [{:optional, true} | acc])
            end
        end
      :error ->
        case Keyword.fetch(kv, :default) do
          :error -> take_options(ctx_or_env, kv, opts, acc)
          {:ok, _any} ->
            take_options(ctx_or_env, kv, opts, [{:optional, true} | acc])
        end
    end
  end

  defp take_options(ctx_or_env, kv, [opt | opts], acc) do
    case Keyword.fetch(kv, opt) do
      :error -> take_options(ctx_or_env, kv, opts, acc)
      {:ok, value} -> take_options(ctx_or_env, kv, opts, [{opt, value} | acc])
    end
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
      false -> Error.comptime(ctx, bad_option(value, name))
      true ->
        case allowed?(allowed, name) do
          true -> _validate(ctx, opts, allowed)
          false -> Error.comptime(ctx, option_not_allowed(name))
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


  defp resolve(ctx_or_env, quoted, key \\ nil)

  defp resolve(ctx_or_env, {:@, _, _} = quoted, key) do
    try do
      case ctx_or_env do
        %Context{} = ctx ->
          {value, []} = Context.eval_quoted(ctx, quoted)
          value
        %Macro.Env{} = env ->
          {value, []} = Code.eval_quoted(quoted, [], env)
          value
      end
    rescue
      [MatchError, CompileError] ->
        if key == nil do
          raise CompileError,
            description: "invalid options: #{inspect quoted}"
        else
          raise CompileError,
            description: "invalid option #{key}: #{inspect quoted}"
        end
    end
  end

  defp resolve(_ctx_or_env, value, _key), do: value

end