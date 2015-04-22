defmodule Extract.Meta.Mode do

  require Extract.Error

  alias Extract.Meta.Mode


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
          Extract.Meta.CodeGen.module_requirements(:defining)
          Extract.Meta.Extracts.setup(__MODULE__, :defining)
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
          Extract.Meta.CodeGen.module_requirements(:using)
          Extract.Meta.Extracts.setup(__MODULE__, :using)
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

end