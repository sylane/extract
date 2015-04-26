defmodule Extract.Meta.CodeGen do

  alias Extract.Meta.Mode
  alias Extract.Meta.Extracts
  alias Extract.Meta.Receipts
  alias Extract.Meta.Mode
  alias Extract.Meta.Ast


  @gen_extracts  :generate_extract_list
  @gen_receipts  :generate_receipt_list
  @gen_validate  :generate_validation
  @gen_validate! :generate_validation!


  defmacro module_requirements(_mode) do
    _ast = quote do
      require Extract
      use Extract.Pipeline
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro using_macro() do
    module = Mode.module(__CALLER__, :defining)
    extracts = Extracts.all(module)
    receipts = Receipts.all(module)
    extracts_requirment = Extracts.required_modules(module)
    receipts_requirment = Receipts.required_modules(module)
    required_modules = extracts_requirment ++ receipts_requirment
    requirments = Enum.into(Enum.into(required_modules, HashSet.new()), [])
    escaped_extracts = for x <- extracts, do: Macro.escape(x)
    escaped_receipts = for r <- receipts, do: Macro.escape(r)
    _ast = quote do
      defmacro __using__(_kv) do
        requirments = unquote(requirments)
        extracts = unquote(escaped_extracts)
        receipts = unquote(escaped_receipts)
        extracts_ast = Extracts.generate_registrations(extracts)
        receipts_ast = Receipts.generate_registrations(receipts)
        requirments_ast = for mod <- unquote(requirments) do
          quote do: require unquote(mod)
        end
        _ast = quote do
          require Extract.Meta.Mode
          Mode.maybe_start_using()
          unquote_splicing(requirments_ast)
          unquote_splicing(extracts_ast)
          unquote_splicing(receipts_ast)
        end
        # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
      end
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro list_functions() do
    module = Mode.module(__CALLER__, :defining)
    ast = case Module.get_attribute(module, @gen_extracts) do
      nil -> []
      name ->
        extracts = Extracts.local(module)
        extract_ids = for x <- extracts, do: x.name
        ast = quote do
          def unquote(name)(), do: unquote(extract_ids)
        end
        [ast]
    end
    ++ case Module.get_attribute(module, @gen_receipts) do
      nil -> []
      name ->
        receipts = Receipts.local(module)
        receipt_ids = for r <- receipts, do: {r.from, r.to}
        ast = quote do
          def unquote(name)(), do: unquote(receipt_ids)
        end
        [ast]
    end
    _ast = quote do
      unquote_splicing(ast)
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro validation_functions() do
    module = Mode.module(__CALLER__, :defining)
    specs = validation_specs(module)
    value_var = Macro.var(:value, __MODULE__)
    _ast = for {macro_mod, macro_fun, gen_fun, fun_specs} <- specs do
      fun_statements = for {fmt, allowed, opts_specs} <- fun_specs do
      # fun_statements = for {fmt, allowed, opts_specs} <- [hd(fun_specs)] do
        match_statements = for {opts_ast, match_ast} <- opts_specs do
          call = Ast.call(macro_mod, macro_fun, [value_var, fmt, opts_ast])
          [statement] = quote do
            #FIXME: Remove this useless encapsulation.
            #       It is required to prevent error 'ambiguous_catch_try_state'
            #       with Erlang versions < 18.
            unquote(match_ast) -> fn -> unquote(call) end.()
          end
          statement
        end
        opts_statment = for o <- allowed do
          quote do: Keyword.fetch(opts, unquote(o))
        end
        if opts_statment == [] do
          call = Ast.call(macro_mod, macro_fun, [value_var, fmt, []])
          quote do
            def unquote(gen_fun)(unquote(value_var), unquote(fmt), _opts) do
              unquote(call)
            end
          end
        else
          quote do
            def unquote(gen_fun)(unquote(value_var), unquote(fmt), opts) do
              opts = unquote(opts_statment)
              case opts do
                unquote(match_statements)
              end
            end
          end
        end
      end
      quote do
        def unquote(gen_fun)(value, format, opts \\ [])
        unquote_splicing(fun_statements)
        def unquote(gen_fun)(_value, format, _opts) do
          Extract.Meta.Error.runtime_bad_format(format)
        end
      end
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defp validation_specs(module) do
    extracts = Extracts.local(module)
    case Module.get_attribute(module, @gen_validate) do
      nil -> []
      fun_name ->
        opts_specs = for x <- extracts do
          opts = Enum.sort(x.opts)
          {x.name, opts, opts_specs(opts)}
        end
        [{Extract, :validate, fun_name, opts_specs}]
    end
    ++
    case Module.get_attribute(module, @gen_validate!) do
      nil -> []
      fun_name ->
        opts_specs = for x <- extracts do
          opts = Enum.sort(x.opts)
          {x.name, opts, opts_specs(opts)}
        end
        [{Extract, :validate!, fun_name, opts_specs}]
    end
  end


  defp opts_specs(opts) do
    vars = for o <- opts, do: Macro.var(o, __MODULE__)
    combinations = Enum.sort(combinate(vars))
    for combination <- combinations do
      opts_ast = for {n ,_, _} = v <- combination, do: {n, v}
      {opts_ast, opts_spec(vars, combination)}
    end
  end


  defp opts_spec(ref, choice), do: opts_spec(ref, choice, [])


  defp opts_spec([], [], acc), do: Enum.reverse(acc)

  defp opts_spec([name | ref], [name | choice], acc) do
    opts_spec(ref, choice, [{:ok, name} | acc])
  end

  defp opts_spec([_ | ref], choice, acc) do
    opts_spec(ref, choice, [:error | acc])
  end


  defp combinate([]), do: [[]]
  defp combinate([h | t]) do
    c = combinate(t)
    c ++ for i <- c, do: [h | i]
  end


  # defmacro generate_distillation_macros() do
  #   {:ok, mod} = callers_module(__CALLER__)
  #   {:ok, receipt_defs} = callers_receipts(__CALLER__)
  #   receipts = Enum.into(receipt_defs, %{})
  #   local_receipts = for {k, {_, m, _}} <- receipts, m == mod, do: k
  #   opts_var = Macro.var(:opts, __MODULE__)
  #   body_var = Macro.var(:body, __MODULE__)
  #   froms = for {f, _} <- local_receipts, do: f
  #   unique_froms = Enum.into(froms, HashSet.new())
  #   from_statements = for from <- unique_froms do
  #     tos = for {f, t} <- local_receipts, f == from, do: t
  #     unique_tos = Enum.into(tos, HashSet.new())
  #     to_statements = for to <- unique_tos do
  #       {_, _, fun} = receipts[{from, to}]
  #       call = {fun, [], [opts_var, body_var]}
  #       [to_statement] = quote do
  #         unquote(to) -> unquote(call)
  #       end
  #       to_statement
  #     end
  #     [from_statement] = quote do
  #       unquote(from) ->
  #         branch to do
  #           unquote(to_statements)
  #         else
  #           Meta.bad_receipt_error from, to
  #         end
  #     end
  #     from_statement
  #   end
  #   _ast = quote do
  #     defmacro _distill(value, from, to,
  #                       unquote(opts_var) \\ [],
  #                       unquote(body_var) \\ []) do
  #       pipeline value, env: __ENV__, caller: __CALLER__, debug: true do
  #       # pipeline value, env: __ENV__, caller: __CALLER__ do
  #         branch from do
  #           unquote(from_statements)
  #         else
  #           Meta.bad_receipt_error from, to
  #         end
  #         Meta.terminate
  #       rescue
  #         Meta.comptime_rescue
  #       end
  #     end
  #     defmacro _distill!(value, from, to,
  #                        unquote(opts_var) \\ [],
  #                        unquote(body_var) \\ []) do
  #       pipeline value, env: __ENV__, caller: __CALLER__, debug: true do
  #       # pipeline value, env: __ENV__, caller: __CALLER__ do
  #         branch from do
  #           unquote(from_statements)
  #         else
  #           Meta.bad_receipt_error from, to
  #         end
  #         Meta.terminate!
  #       rescue
  #         Meta.comptime_rescue!
  #       end
  #     end
  #     defmacro _distill!(ast, ctx, from, to,
  #                        unquote(opts_var),
  #                        unquote(body_var)) do
  #       pipeline ast, ctx do
  #         branch from do
  #           unquote(from_statements)
  #         else
  #           Meta.bad_receipt_error from, to
  #         end
  #       end
  #     end
  #   end
  #   # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  # end

end