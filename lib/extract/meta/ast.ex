defmodule Extract.Meta.Ast do


  def call(fun, args)
   when is_atom(fun) and is_list(args) do
    {fun, [], args}
  end

  def call(path, fun, args)
   when is_list(path) and is_atom(fun) and is_list(args) do
    {{:., [], [{:__aliases__, [alias: false], path}, fun]}, [], args}
  end

  def call(mod, fun, args) when is_atom(fun) and is_list(args) do
    {{:., [], [mod, fun]}, [], args}
  end


  def comptime?([]), do: true

  def comptime?(ast) when is_atom(ast), do: true

  def comptime?(ast) when is_number(ast), do: true

  def comptime?(ast) when is_binary(ast), do: true

  def comptime?([value | rem]) do
    comptime?(value) and comptime?(rem)
  end

  def comptime?({:|, _, [a, b]}) do
    comptime?(a) and comptime?(b)
  end
  def comptime?({key, val}) do
    comptime?(key) and comptime?(val)
  end

  def comptime?({:{}, _, items}) when is_list(items) do
    Enum.all?(for v <- items, do: comptime?(v))
  end

  def comptime?({:%{}, _, items}) when is_list(items) do
    Enum.all?(for v <- items, do: comptime?(v))
  end

  def comptime?(_any), do: false

end