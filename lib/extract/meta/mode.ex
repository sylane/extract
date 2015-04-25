defmodule Extract.Meta.Mode do

  require Extract.Error

  alias Extract.Meta.Mode
  alias Extract.Meta.Extracts
  alias Extract.Meta.Receipts
  alias Extract.Meta.CodeGen


  @attribute_name :extract_mode


  defmacro start_defining() do
    _ast = case Mode.get(__CALLER__.module) do
      :defining -> nil
      :using ->
        raise Extract.Error,
          reason: :compilation_error,
          message: "use Extract module before using any other custom modules"
      nil ->
        Mode.set(__CALLER__.module, :defining)
        quote do
          require Extract.Meta.CodeGen
          require Extract.Meta.Extracts
          require Extract.Meta.Receipts
          CodeGen.module_requirements(:defining)
          Extracts.setup(__MODULE__, :defining)
          Receipts.setup(__MODULE__, :defining)
          @before_compile Extract
        end
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro maybe_start_using() do
    _ast = case Mode.get(__CALLER__.module) do
      :using -> nil
      :defining -> nil
      nil ->
        Mode.set(__CALLER__.module, :using)
        quote do
          require Extract.Meta.CodeGen
          require Extract.Meta.Extracts
          require Extract.Meta.Receipts
          CodeGen.module_requirements(:using)
          Extracts.setup(__MODULE__, :using)
          Receipts.setup(__MODULE__, :using)
        end
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  def set(module, mode) do
    Module.put_attribute(module, @attribute_name, mode)
  end


  def get(module) do
    Module.get_attribute(module, @attribute_name)
  end


  def module(env, mode \\ :any)

  def module(env, :any) do
    modules = [env.module | env.context_modules]
    case search_module(modules, :using) do
      {:ok, module} -> module
      :error ->
        case search_module(modules, :defining) do
          {:ok, module} -> module
          :error ->
            msg = "cannot find any extract-managed module "
                  <> "in current macro context: #{inspect modules}"
            raise Extract.Error, reason: :compilation_error, message: msg
        end
    end
  end

  def module(env, mode) do
    modules = [env.module | env.context_modules]
    case search_module(modules, mode) do
      {:ok, module} -> module
      :error ->
        msg = "cannot find any extract-managed module in #{mode} mode "
              <> "in current macro context: #{inspect modules}"
        raise Extract.Error, reason: :compilation_error, message: msg
    end
  end


  defp safe_get(module) do
    try do
      {:ok, get(module)}
    rescue
      ArgumentError -> :error
    end
  end


  defp search_module([], _mode), do: :error

  defp search_module([mod | modules], mode) do
    case safe_get(mod) do
      {:ok, ^mode} -> {:ok, mod}
      _other -> search_module(modules, mode)
    end
  end

end
