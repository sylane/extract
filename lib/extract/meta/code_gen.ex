defmodule Extract.Meta.CodeGen do

  alias Extract.Meta.Extracts


  defmacro module_requirements(_mode) do
    _ast = quote do
      require Extract
      use Extract.Pipeline
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro using_macro() do
    extracts = Extracts.registered(__CALLER__.module)
    required_modules = Extracts.required_modules(__CALLER__.module)
    escaped_extracts = for x <- extracts, do: Macro.escape(x)
    _ast = quote do
      defmacro __using__(_kv) do
        required_modules = unquote(required_modules)
        extracts = unquote(escaped_extracts)
        extracts_ast = Extracts.generate_registrations(extracts)
        requirments_ast = for mod <- unquote(required_modules) do
          quote do: require unquote(mod)
        end
        _ast = quote do
          require Extract.Meta.Mode
          Extract.Meta.Mode.maybe_start_using()
          unquote_splicing(requirments_ast)
          unquote_splicing(extracts_ast)
        end
        # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
      end
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro validation_functions() do
    extracts = Extracts.registered(__CALLER__.module)
    ast_validate = for x <- extracts, x.parent == __CALLER__.module do
      name = x.name
      quote do
        def validate(value, unquote(name), _opts) do
          Extract.validate(value, unquote(name))
        end
      end
    end
    ast_validate! = for x <- extracts, x.parent == __CALLER__.module do
      name = x.name
      quote do
        def validate!(value, unquote(name), _opts) do
          Extract.validate!(value, unquote(name))
        end
      end
    end
    _ast = quote do
      def validate(value, format, opts \\ [])
      unquote_splicing(ast_validate)
      def validate!(value, format, opts \\ [])
      unquote_splicing(ast_validate!)
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
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
  #   from_statments = for from <- unique_froms do
  #     tos = for {f, t} <- local_receipts, f == from, do: t
  #     unique_tos = Enum.into(tos, HashSet.new())
  #     to_statments = for to <- unique_tos do
  #       {_, _, fun} = receipts[{from, to}]
  #       call = {fun, [], [opts_var, body_var]}
  #       [to_statment] = quote do
  #         unquote(to) -> unquote(call)
  #       end
  #       to_statment
  #     end
  #     [from_statment] = quote do
  #       unquote(from) ->
  #         branch to do
  #           unquote(to_statments)
  #         else
  #           Meta.bad_receipt_error from, to
  #         end
  #     end
  #     from_statment
  #   end
  #   _ast = quote do
  #     defmacro _distill(value, from, to,
  #                       unquote(opts_var) \\ [],
  #                       unquote(body_var) \\ []) do
  #       pipeline value, env: __ENV__, caller: __CALLER__, debug: true do
  #       # pipeline value, env: __ENV__, caller: __CALLER__ do
  #         branch from do
  #           unquote(from_statments)
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
  #           unquote(from_statments)
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
  #           unquote(from_statments)
  #         else
  #           Meta.bad_receipt_error from, to
  #         end
  #       end
  #     end
  #   end
  #   # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  # end

end