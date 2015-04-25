defmodule Extract.Meta.Receipts do

  alias Extract.Meta.Receipts
  alias Extract.Meta.Ast


  defstruct [:from, :to, :desc, :parent, :mod, :fun]

  @attribute_name :registered_receipts


  def setup(module, _mode) do
    Module.register_attribute(module, @attribute_name, accumulate: true)
  end


  def new(from, to, desc, parent, fun)
   when is_atom(from) and is_atom(to) and is_binary(desc) and is_atom(fun) do
    module = Module.concat(parent, :Meta)
    %Receipts{from: from, to: to, desc: desc, parent: parent,
              mod: module, fun: fun}
  end


  def register(from, to, desc, module, fun) do
    append(module, new(from, to, desc, module, fun))
  end


  def all(module) do
    collection = Module.get_attribute(module, @attribute_name)
    for {_, extract} <- collection, do: extract
  end


  def local(module) do
    collection = Module.get_attribute(module, @attribute_name)
    for {_, extract} <- collection, extract.parent == module, do: extract
  end


  def required_modules(module) do
    collection = Module.get_attribute(module, @attribute_name)
    all = for {_, extract} <- collection, do: extract.parent
    Enum.into(Enum.into(all, HashSet.new()), [])
  end


  def append(module, receipt) do
    case fetch(module, receipt.from, receipt.to) do
      :error -> _append(module, receipt)
      {:ok, ^receipt} -> :ok
      {:ok, old} ->
        key = {receipt.from, receipt.to}
        raise Extract.Error,
          reason: {:receipt_already_defined, {key, old.parent}},
          message: "receipt #{receipt.desc} already "
                   <> "defined in module #{inspect old.parent}"
    end
  end


  def fetch(module, from, to) do
    key = {from, to}
    collection = Module.get_attribute(module, @attribute_name)
    case List.keyfind(collection, key, 0) do
      nil -> :error
      {_, result} -> {:ok, result}
    end
  end


  def comptime(extract, args) do
    apply(extract.mod, extract.fun, args)
  end


  def runtime(extract, args) do
    Ast.call(extract.mod, extract.fun, args)
  end


  def generate_registrations(receipts) do
    for r <- receipts do
      escaped = Macro.escape(r)
      quote do
        Receipts.append(__MODULE__, unquote(escaped))
      end
    end
  end


  defp _append(module, receipt) do
    key = {receipt.from, receipt.to}
    Module.put_attribute(module, @attribute_name, {key, receipt})
  end

end