defmodule Extract.Meta.Context do

  require Extract.Meta.Debug

  alias Extract.Meta.Context
  alias Extract.Meta.Debug


  defstruct [env: nil,
             caller: nil,
             missing: nil,
             undefined: nil,
             need_rescue: false]


  def start(value, kv \\ []) do
    env = Keyword.get(kv, :env, nil)
    caller = Keyword.get(kv, :caller, nil)
    undefined = Keyword.get(kv, :undefined, nil)
    missing = Keyword.get(kv, :undefined, nil)
    context = %Context{env: cleanup_env(env), caller: cleanup_env(caller),
                       undefined: undefined, missing: missing}
    case value do
      ^undefined -> {:undefined, context}
      other when is_atom(value) or is_binary(value) or is_number(value) ->
        {{:value, other}, context}
      other ->
        ast = quote do
          case unquote(other) do
            unquote(undefined) -> :undefined
            other -> {:value, other}
          end
        end
        {ast, context}
    end
  end


  def terminate!({:missing, %Context{missing: missing}}) do
    quote do: unquote(missing)
  end

  def terminate!({:undefined, %Context{undefined: undefined}}) do
    quote do: unquote(undefined)
  end

  def terminate!({{:value, value}, %Context{}})
   when is_atom(value) or is_binary(value) or is_number(value) do
    quote do: unquote(value)
  end

  def terminate!({ast, %Context{undefined: undefined, missing: missing}}) do
    quote do
      case unquote(ast) do
        :undefined -> unquote(undefined)
        :missing -> unquote(missing)
        {:value, value} -> value
      end
    end
  end


  def terminate({:missing, %Context{missing: missing}}) do
    quote do: {:ok, unquote(missing)}
  end

  def terminate({:undefined, %Context{undefined: undefined}}) do
    quote do: {:ok, unquote(undefined)}
  end

  def terminate({{:value, value}, %Context{}})
   when is_atom(value) or is_binary(value) or is_number(value) do
    quote do: {:ok, unquote(value)}
  end

  def terminate({ast, %Context{need_rescue: false} = context}) do
    #TODO: may remove the :missing match if not required like for :need_rescue
    %Context{undefined: undefined, missing: missing} = context
    quote do
      case unquote(ast) do
        :undefined -> {:ok, unquote(undefined)}
        :missing -> {:ok, unquote(missing)}
        {:value, value} -> {:ok, value}
      end
    end
  end

  def terminate({ast, %Context{need_rescue: true} = context}) do
    #TODO: may remove the :missing match if not required like for :need_rescue
    %Context{undefined: undefined, missing: missing} = context
    quote do
      try do
        case unquote(ast) do
          :undefined -> {:ok, unquote(undefined)}
          :missing -> {:ok, unquote(missing)}
          {:value, value} -> {:ok, value}
        end
      rescue
        e in Extract.Error -> {:error, e.reason}
      end
    end
  end


  def debug(param, kv \\ [])

  def debug({ast, %Context{env: env, caller: caller} = context}, kv) do
    debug_env = Keyword.get(kv, :env, env)
    debug_caller = Keyword.get(kv, :caller, caller)
    {Debug.ast(ast, env: debug_env, caller: debug_caller), context}
  end

  def debug(ast, kv) do
    debug_env = Keyword.get(kv, :env)
    debug_caller = Keyword.get(kv, :caller)
    Debug.ast(ast, env: debug_env, caller: debug_caller)
  end


  def merge(%Context{} = context, children) when is_list(children) do
    need_rescue = Enum.any?(children, fn %Context{need_rescue: f} -> f end)
    %Context{context | need_rescue: need_rescue}
  end


  def need_rescue(%Context{} = context) do
    %Context{context | need_rescue: true}
  end


  defp cleanup_env(env) do
    %Elixir.Macro.Env{env | functions: nil, macros: nil}
  end
end
