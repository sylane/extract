defmodule TestHelper do

  defmacro __using__(_) do
    quote do
      use ExUnit.Case, async: false
      use ExCheck
      require TestCompiler
      import TestHelper, only: :macros
      import TestCompiler, only: :macros
    end
  end


  defmacro assert_valid(exp, val, fmt, opts \\ []) do
    _ast = quote location: :keep do
      val = unquote(val)
      fmt = unquote(fmt)
      opts = unquote(opts)
      expect_result({:ok, unquote(exp)},
        Extract.BasicTypes.validate(static: val, static: fmt, attribute_kw: opts))
      expect_result({:ok, unquote(exp)},
        Extract.BasicTypes.validate(static: val, static: fmt, static_kw: opts))
      expect_result({:ok, unquote(exp)},
        Extract.BasicTypes.validate(dynamic: val, static: fmt, static_kw: opts))
      expect_result({:ok, unquote(exp)},
        Extract.BasicTypes.validate(static: val, dynamic: fmt, static_kw: opts))
      expect_result({:ok, unquote(exp)},
        Extract.BasicTypes.validate(dynamic: val, dynamic: fmt, static_kw: opts))
      expect_result(unquote(exp),
        Extract.BasicTypes.validate!(static: val, static: fmt, attribute_kw: opts))
      expect_result(unquote(exp),
        Extract.BasicTypes.validate!(static: val, static: fmt, static_kw: opts))
      expect_result(unquote(exp),
        Extract.BasicTypes.validate!(dynamic: val, static: fmt, static_kw: opts))
      expect_result(unquote(exp),
        Extract.BasicTypes.validate!(static: val, dynamic: fmt, static_kw: opts))
      expect_result(unquote(exp),
        Extract.BasicTypes.validate!(dynamic: val, dynamic: fmt, static_kw: opts))
      true
    end
    # Extract.Meta.Debug.ast(_ast, info: "assert_valid")
  end


  defmacro assert_invalid(exp, val, fmt, opts \\ []) do
    _ast = quote location: :keep do
      val = unquote(val)
      fmt = unquote(fmt)
      opts = unquote(opts)
      expect_result({:error, unquote(exp)},
        Extract.BasicTypes.validate(static: val, static: fmt, attribute_kw: opts))
      expect_result({:error, unquote(exp)},
        Extract.BasicTypes.validate(static: val, static: fmt, static_kw: opts))
      expect_result({:error, unquote(exp)},
        Extract.BasicTypes.validate(dynamic: val, static: fmt, static_kw: opts))
      expect_result({:error, unquote(exp)},
        Extract.BasicTypes.validate(static: val, dynamic: fmt, static_kw: opts))
      expect_result({:error, unquote(exp)},
        Extract.BasicTypes.validate(dynamic: val, dynamic: fmt, static_kw: opts))
      expect_raise(unquote(exp),
        Extract.BasicTypes.validate!(static: val, static: fmt, attribute_kw: opts))
      expect_raise(unquote(exp),
        Extract.BasicTypes.validate!(static: val, static: fmt, static_kw: opts))
      expect_raise(unquote(exp),
        Extract.BasicTypes.validate!(dynamic: val, static: fmt, static_kw: opts))
      expect_raise(unquote(exp),
        Extract.BasicTypes.validate!(static: val, dynamic: fmt, static_kw: opts))
      expect_raise(unquote(exp),
        Extract.BasicTypes.validate!(dynamic: val, dynamic: fmt, static_kw: opts))
      true
    end
    # Extract.Meta.Debug.ast(_ast, info: "assert_invalid")
  end

end


defmodule TestCompiler do

  defmacro execute(call) do
    ast = _execute(call)
    quote do
      case unquote(ast) do
        {:ok, result, _} -> result
        {:error, {error, trace}, _} -> reraise error, trace
      end
    end
  end


  defmacro expect_result(expected, call) do
    ast = _execute(call)
    exp_str = Macro.to_string(expected)
    _ast = quote do
      case unquote(ast) do
        {:ok, unquote(expected) = result, _} -> result
        {:ok, other, desc} ->
          raise ExUnit.AssertionError,
            right: other,
            expr: unquote(exp_str) <> " = " <> desc,
            message: "match (=) failed"
        {:error, {error, _}, desc} ->
          raise ExUnit.AssertionError,
            expr: unquote(exp_str) <> " = " <> desc,
            message: "expected result but got Extract.Error with "
                     <> "reason #{inspect error.reason}"
      end
    end
    # Extract.Meta.Debug.ast(_ast, info: "expect_result")
  end


  defmacro expect_raise(reason, call) do
    ast = _execute(call)
    exp_str = Macro.to_string(reason)
    _ast = quote do
      case unquote(ast) do
        {:ok, result, desc} ->
          raise ExUnit.AssertionError,
            right: result,
            expr: desc,
            message: "expected Extract.Error with reason #{unquote(exp_str)}"
        {:error, {error, _}, desc} ->
          case error.reason do
            unquote(reason) -> error
            other ->
              raise ExUnit.AssertionError,
                expr: desc,
                message: "expected Extract.Error with reason #{unquote(exp_str)} "
                         <> "but got one with reason #{inspect other}"
          end
      end
    end
    # Extract.Meta.Debug.ast(_ast, info: "expect_raise")
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


  defp _execute(call) do
    {{:., _, [{:__aliases__, _, _} = mod, _]} = fun, ctx, [specs]} = call
    use_ast = {:use, [context: Elixir, import: Kernel], [mod]}
    escaped_use = Macro.escape(use_ast)
    escaped_fun = Macro.escape(fun)
    escaped_ctx = Macro.escape(ctx)
    _macro_ast = quote do
      use_ast = unquote(escaped_use)
      fun_ast = unquote(escaped_fun)
      ctx_ast = unquote(escaped_ctx)
      module = unquote(mod)
      {attrs, vars, args, params} = TestCompiler._prepare(unquote(specs))
      call_ast = {fun_ast, ctx_ast, args}
      call_desc = Macro.to_string(call_ast)
      dyn_prarms = for {{name, _, _}, value} <- Enum.zip(vars, params) do
        "#{name} = #{inspect value}"
      end
      dyn_attribs = for {:@, _, [{name, _, [value]}]} <- attrs do
        "@#{name} = #{inspect value}"
      end
      desc = case dyn_prarms ++ dyn_attribs do
        [] -> call_desc
        extra -> call_desc <> " with " <> Enum.join(extra, ", ")
      end

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
      try do
        result = apply(TestCompiler.Dynamic, :test, params)
        {:ok, result, desc}
      rescue
        error in Extract.Error ->
          {:error, {error, System.stacktrace()}, desc}
      end
    end
    # Extract.Meta.Debug.ast(_macro_ast, info: "dynamic test")
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
