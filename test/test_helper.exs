defmodule TestHelper do

end


defmodule TestCompiler do

  defmacro execute(call) do
    {{:., _, [{:__aliases__, _, _} = mod, _]} = fun, ctx, [specs]} = call
    use_ast = {:use, [context: Elixir, import: Kernel], [mod]}
    escaped_use = Macro.escape(use_ast)
    escaped_fun = Macro.escape(fun)
    escaped_ctx = Macro.escape(ctx)
    quote do
      use_ast = unquote(escaped_use)
      fun_ast = unquote(escaped_fun)
      ctx_ast = unquote(escaped_ctx)
      module = unquote(mod)
      {attrs, vars, args, params} = TestCompiler._prepare(unquote(specs))
      call_ast = {fun_ast, ctx_ast, args}
      mod_ast = quote do
        defmodule TestCompiler.Dynamic do
          unquote(use_ast)
          unquote_splicing(attrs)
          def test(unquote_splicing(vars)) do
            unquote(call_ast)
          end
        end
      end
      # Extract.Meta.Debug.ast(mod_ast, info: "dynamic module")
      Code.compiler_options(ignore_module_conflict: true)
      {{:module, _, _, {:test, _}}, []} = Code.eval_quoted(mod_ast)
      apply(TestCompiler.Dynamic, :test, params)
    end
  end


  def _prepare(specs) do
    _prepare(Enum.with_index(specs), [], [], [], [])
  end

  def _prepare([], attrs, vars, args, tests) do
    {Enum.reverse(attrs), Enum.reverse(vars),
     Enum.reverse(args), Enum.reverse(tests)}
  end

  def _prepare([{{:static, val}, _} | specs], attrs, vars, args, tests) do
    _prepare(specs, attrs, vars, [value(val) | args], tests)
  end

  def _prepare([{{:dynamic, val}, i} | specs], attrs, vars, args, tests) do
    var = variable(i)
    _prepare(specs, attrs, [var | vars], [var | args], [val | tests])
  end

  def _prepare([{{:attribute, val}, i} | specs], attrs, vars, args, tests) do
    attr_def = attribute_def(i, val)
    attr_ref = attribute_ref(i)
    _prepare(specs, [attr_def | attrs], vars, [attr_ref | args], tests)
  end

  def _prepare([{{:static_kw, kw}, _} | specs], attrs, vars, args, tests) do
    val = for {k, v} <- kw, do: {k, value(v)}
    _prepare(specs, attrs, vars, [val | args], tests)
  end

  def _prepare([{{:attribute_kw, kw}, i} | specs], attrs, vars, args, tests) do
    defs = for {{_, v}, j} <- Enum.with_index(kw), do: attribute_def(i, j, v)
    val = for {{k, _}, j} <- Enum.with_index(kw), do: {k, attribute_ref(i, j)}
    _prepare(specs, Enum.reverse(defs) ++ attrs, vars, [val | args], tests)
  end


  defp value(val), do: Macro.escape(val)


  defp variable(i) do
    Macro.var(String.to_atom("param" <> to_string(i)), __MODULE__)
  end


  defp attribute_ref(i) do
    name = attribute_name(i)
    {:@, [context: Elixir, import: Kernel], [{name, [], Elixir}]}
  end

  defp attribute_ref(i, j) do
    name = attribute_name(i, j)
    {:@, [context: Elixir, import: Kernel], [{name, [], Elixir}]}
  end


  defp attribute_def(i, value) do
    name = attribute_name(i)
    escaped = Macro.escape(value)
    {:@, [context: Elixir, import: Kernel], [{name, [], [escaped]}]}
  end

  defp attribute_def(i, j, value) do
    name = attribute_name(i, j)
    escaped = Macro.escape(value)
    {:@, [context: Elixir, import: Kernel], [{name, [], [escaped]}]}
  end


  defp attribute_name(i), do: String.to_atom("attribute_" <> to_string(i))


  defp attribute_name(i, j) do
    String.to_atom("attribute_" <> to_string(i) <> "_" <> to_string(j))
  end

end


ExUnit.start()
