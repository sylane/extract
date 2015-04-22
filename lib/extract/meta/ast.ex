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

end