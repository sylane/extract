defmodule Extract.Meta.Extracts do

  alias Extract.Meta.Extracts

  defstruct [:name, :parent, :mod, :fun, :opts]

  @attribute_name :registered_extracts


  def setup(module, _mode) do
    Module.register_attribute(module, @attribute_name, accumulate: true)
  end


  def new(name, desc, parent, fun, opts)
   when is_atom(name) and is_binary(desc)
   and is_atom(fun) and is_list(opts) do
    module = Module.concat(parent, :Meta)
    %Extracts{name: name, parent: parent, mod: module, fun: fun, opts: opts}
  end


  def register(name, desc, module, fun, opts \\ []) do
    extract = Extracts.new(name, desc, module, fun, opts)
    Extracts.append(module, extract)
  end


  def registered(module) do
    collection = Module.get_attribute(module, @attribute_name)
    for {_, extract} <- collection, do: extract
  end


  def required_modules(module) do
    collection = Module.get_attribute(module, @attribute_name)
    all = for {_, extract} <- collection, do: extract.parent
    Enum.into(Enum.into(all, HashSet.new()), [])
  end


  def append(module, extract) do
    case fetch(module, extract.name) do
      :error -> _append(module, extract)
      {:ok, ^extract} -> :ok
      {:ok, old} ->
        raise Extract.Error,
          reason: {:extract_already_defined, {extract.name, old.mod}},
          message: "extract #{extract.name} already "
                   <> "defined in module #{inspect old.mod}"
    end
  end


  def fetch(module, name) do
    collection = Module.get_attribute(module, @attribute_name)
    case List.keyfind(collection, name, 0) do
      nil -> :error
      {_, result} -> {:ok, result}
    end
  end


  def call(extract, ast, ctx, opts, body) do
    apply(extract.mod, extract.fun, [ast, ctx, opts, body])
  end


  def generate_registrations(extracts) do
    for x <- extracts do
      escaped = Macro.escape(x)
      quote do
        Extracts.append(__MODULE__, unquote(escaped))
      end
    end
  end


  defp _append(module, extract) do
    Module.put_attribute(module, @attribute_name, {extract.name, extract})
  end

end