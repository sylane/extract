defmodule Extract do

  require Extract.Meta
  require Extract.Meta.Error
  require Extract.Util
  require Extract.Valid
  require Extract.Trans

  alias Extract.Meta
  alias Extract.Meta.Ast
  alias Extract.Meta.Error



  defmacro validate!(value, format, opts \\ [], body \\ []) do
    #FIXME: handle context errors (call from non-managed modules)
    {:ok, extract_defs} = callers_extracts(__CALLER__)
    _ast = case List.keyfind(extract_defs, format, 0) do
      nil -> Error.comptime_bad_format(format)
      {_, {_, mod, _}} ->
        Ast.call(mod, :_validate!, [value, format, opts, body])
    end
    Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro validate(value, format, opts \\ [], body \\ []) do
    #FIXME: handle context errors (call from non-managed modules)
    {:ok, extract_defs} = callers_extracts(__CALLER__)
    _ast = case List.keyfind(extract_defs, format, 0) do
      nil -> {:error, {:bad_format, format}}
      {_, {_, mod, _}} ->
        Ast.call(mod, :_validate, [value, format, opts, body])
    end
    Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro validate!(ast, ctx, fmt, opts, body) do
    #FIXME: handle context errors (call from non-managed modules)
    {:ok, extract_defs} = callers_extracts(__CALLER__)
    _ast = case List.keyfind(extract_defs, fmt, 0) do
      nil -> Error.comptime_bad_format(fmt)
      {_, {_, mod, _}} ->
        Ast.call(mod, :_validate!, [ast, ctx, fmt, opts, body])
    end
    Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro __using__(_) do
    _ast = quote do
      require Extract
      Extract.start_defining()
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro start_defining() do
    _ast = quote do
      use Extract.Pipeline
      require Extract.Meta.Debug
      require Extract.Meta.Options
      require Extract.Meta.Context
      require Extract.Meta.Error
      require Extract.Meta
      require Extract.Trans
      require Extract.Valid
      require Extract.Util
      if Extract.using? do
        raise Extract.Error,
          message: "use Extract module before using any other custom modules"
      end
      if not Extract.defining? do
        Extract.defining(true)
        Extract.using(false)
        Module.register_attribute(__MODULE__,
          :registered_extracts, accumulate: true)
        Module.register_attribute(__MODULE__,
          :registered_receipts, accumulate: true)
        @before_compile Extract
      end
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro maybe_start_using() do
    _ast = quote do
      require Extract
      require Extract.Meta.Debug
      require Extract.Meta.Options
      require Extract.Meta.Context
      require Extract.Meta.Error
      require Extract.Meta
      require Extract.Trans
      require Extract.Valid
      require Extract.Util
      if not Extract.defining? do
        if not Extract.using? do
          Extract.using(true)
          Extract.defining(false)
          Module.register_attribute(__MODULE__,
            :registered_extracts, accumulate: true)
          Module.register_attribute(__MODULE__,
            :registered_receipts, accumulate: true)
        end
      end
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro defining?() do
    quote do
      # Using the function to not get a waring when undefined.
      Module.get_attribute(__MODULE__, :defining_extract) == true
    end
  end


  defmacro defining(flag) when is_boolean(flag) do
    quote do: @defining_extract unquote(flag)
  end


  defmacro using?() do
    quote do
      # Using the function to not get a waring when undefined.
      Module.get_attribute(__MODULE__, :using_extract) == true
    end
  end


  defmacro using(flag) when is_boolean(flag) do
    quote do: @using_extract unquote(flag)
  end


  defmacro register_extract(extract, desc, module, fun)
   when is_binary(desc) and is_atom(extract) and is_atom(fun) do
    quote do
      case List.keyfind(@registered_extracts, unquote(extract), 0) do
        nil ->
          @registered_extracts {unquote(extract),
            {unquote(desc), unquote(module), unquote(fun)}}
        {_, {_, old_mod, _}} ->
          raise Extract.Error,
            reason: {:extract_already_defined, {unquote(extract), old_mod}},
            message: "extract #{unquote(extract)} already "
                     <> "defined in module #{inspect old_mod}"
      end
    end
  end


  defmacro register_extract(extract, desc, fun)
   when is_binary(desc) and is_atom(extract) and is_atom(fun) do
    quote do
      Extract.register_extract(unquote(extract), unquote(desc),
                               __MODULE__, unquote(fun))
    end
  end


  defmacro register_receipt({from, to} = receipt, desc, module, fun)
   when is_binary(desc) and is_atom(from) and is_atom(to) and is_atom(fun) do
    quote do
      case List.keyfind(@registered_receipts, unquote(receipt), 0) do
        nil ->
          @registered_receipts {unquote(receipt),
            {unquote(desc), unquote(module), unquote(fun)}}
        {_, {_, old_mod, _}} ->
          raise Extract.Error,
            reason: {:receipt_already_defined, {unquote(receipt), old_mod}},
            message: "receipt #{unquote(from)} -> #{unquote(to)} already "
                     <> "defined in module #{inspect old_mod}"
      end
    end
  end


  defmacro register_receipt({from, to} = receipt, desc, fun)
   when is_binary(desc) and is_atom(from) and is_atom(to) and is_atom(fun) do
    quote do
      Extract.register_receipt(unquote(receipt), unquote(desc),
                               __MODULE__, unquote(fun))
    end
  end


  defmacro registered_extracts() do
    quote do: @registered_extracts
  end


  defmacro registered_receipts() do
    quote do: @registered_receipts
  end


  defmacro generate_validation_macros() do
    {:ok, mod} = callers_module(__CALLER__)
    {:ok, extract_defs} = callers_extracts(__CALLER__)
    opts_var = Macro.var(:opts, __MODULE__)
    body_var = Macro.var(:body, __MODULE__)
    branch_statments = for {t, {_, m, f}} <- extract_defs, m == mod do
      call = {f, [], [opts_var, body_var]}
      [statment] = quote do
        unquote(t) -> unquote(call)
      end
      statment
    end
    _ast = quote do
      defmacro _validate(value, format,
                         unquote(opts_var) \\ [],
                         unquote(body_var) \\ []) do
        # pipeline value, env: __ENV__, caller: __CALLER__, debug: true do
        pipeline value, env: __ENV__, caller: __CALLER__ do
          branch format do
            unquote(branch_statments)
          else
            Meta.bad_format_error format
          end
          Meta.terminate
        rescue
          Meta.comptime_rescue
        end
      end
      defmacro _validate!(value, format,
                          unquote(opts_var) \\ [],
                          unquote(body_var) \\ []) do
        # pipeline value, env: __ENV__, caller: __CALLER__, debug: true do
        pipeline value, env: __ENV__, caller: __CALLER__ do
          branch format do
            unquote(branch_statments)
          else
            Meta.bad_format_error format
          end
          Meta.terminate!
        rescue
          Meta.comptime_rescue!
        end
      end
      defmacro _validate!(ast, ctx, format,
                          unquote(opts_var),
                          unquote(body_var)) do
        pipeline ast, ctx do
          branch format do
            unquote(branch_statments)
          else
            Meta.bad_format_error format
          end
        end
      end
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro generate_distillation_macros() do
    {:ok, mod} = callers_module(__CALLER__)
    {:ok, receipt_defs} = callers_receipts(__CALLER__)
    receipts = Enum.into(receipt_defs, %{})
    local_receipts = for {k, {_, m, _}} <- receipts, m == mod, do: k
    opts_var = Macro.var(:opts, __MODULE__)
    body_var = Macro.var(:body, __MODULE__)
    froms = for {f, _} <- local_receipts, do: f
    unique_froms = Enum.into(froms, HashSet.new())
    from_statments = for from <- unique_froms do
      tos = for {f, t} <- local_receipts, f == from, do: t
      unique_tos = Enum.into(tos, HashSet.new())
      to_statments = for to <- unique_tos do
        {_, _, fun} = receipts[{from, to}]
        call = {fun, [], [opts_var, body_var]}
        [to_statment] = quote do
          unquote(to) -> unquote(call)
        end
        to_statment
      end
      [from_statment] = quote do
        unquote(from) ->
          branch to do
            unquote(to_statments)
          else
            Meta.bad_receipt_error from, to
          end
      end
      from_statment
    end
    _ast = quote do
      defmacro _distill(value, from, to,
                        unquote(opts_var) \\ [],
                        unquote(body_var) \\ []) do
        pipeline value, env: __ENV__, caller: __CALLER__, debug: true do
        # pipeline value, env: __ENV__, caller: __CALLER__ do
          branch from do
            unquote(from_statments)
          else
            Meta.bad_receipt_error from, to
          end
          Meta.terminate
        rescue
          Meta.comptime_rescue
        end
      end
      defmacro _distill!(value, from, to,
                         unquote(opts_var) \\ [],
                         unquote(body_var) \\ []) do
        pipeline value, env: __ENV__, caller: __CALLER__, debug: true do
        # pipeline value, env: __ENV__, caller: __CALLER__ do
          branch from do
            unquote(from_statments)
          else
            Meta.bad_receipt_error from, to
          end
          Meta.terminate!
        rescue
          Meta.comptime_rescue!
        end
      end
      defmacro _distill!(ast, ctx, from, to,
                         unquote(opts_var),
                         unquote(body_var)) do
        pipeline ast, ctx do
          branch from do
            unquote(from_statments)
          else
            Meta.bad_receipt_error from, to
          end
        end
      end
    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defmacro __before_compile__(_env) do
    _ast = quote do

      defmacro __using__(_kv) do
        extract_defs = Extract.registered_extracts()
        receipts_defs = Extract.registered_receipts()
        unique_extract_defs = Enum.into(extract_defs, HashSet.new())
        unique_receipt_defs = Enum.into(receipts_defs, HashSet.new())
        mods = for {_, {_, m, _}} <- extract_defs ++ receipts_defs, do: m
        unique_mods = Enum.into(mods, HashSet.new())
        extract_regs = for {extract, {desc, mod, fun}} <- unique_extract_defs do
          quote do
            Extract.register_extract(unquote(extract), unquote(desc),
                                     unquote(mod), unquote(fun))
          end
        end
        receipt_regs = for {receipt, {desc, mod, fun}} <- unique_receipt_defs do
          quote do
            Extract.register_receipt(unquote(receipt), unquote(desc),
                                     unquote(mod), unquote(fun))
          end
        end
        mod_requirments = for mod <- unique_mods do
          quote do
            require unquote(mod)
          end
        end
        _ast = quote do
          require Extract
          Extract.maybe_start_using
          unquote_splicing(mod_requirments)
          unquote_splicing(extract_regs)
          unquote_splicing(receipt_regs)
        end
        # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
      end

      Extract.generate_validation_macros
      Extract.generate_distillation_macros

      # alias Extract.Meta
      # alias Extract.Meta.Error


      # defmacro validate(value, format, opts \\ [], body \\ []) do
      #   pipeline value, env: __ENV__, caller: __CALLER__, debug: true do
      #     Extract._extract_branches format, opts, body
      #     Meta.terminate
      #   rescue
      #     Meta.comptime_rescue
      #   end
      # end


      # defmacro validate!(value, format, opts \\ [], body \\[]) do
      #   pipeline value, env: __ENV__, caller: __CALLER__, debug: true do
      #     Extract._extract_branches format, opts, body
      #     Meta.terminate!
      #   rescue
      #     Meta.comptime_rescue!
      #   end
      # end

    end
    # Extract.Meta.Debug.ast(_ast, env: __ENV__, caller: __CALLER__)
  end


  defp callers_module(env) do
    case Map.get(env, :module) do
      nil -> {:error, :module_not_found}
      mod -> {:ok, mod}
    end
  end


  defp callers_extracts(env) do
    case callers_module(env) do
      {:error, _} = error -> error
      {:ok, mod} ->
        case Module.get_attribute(mod, :registered_extracts) do
          nil -> {:error, :attribute_not_found}
          result -> {:ok, result}
        end
    end
  end


  defp callers_receipts(env) do
    case callers_module(env) do
      {:error, _} = error -> error
      {:ok, mod} ->
        case Module.get_attribute(mod, :registered_receipts) do
          nil -> {:error, :attribute_not_found}
          result -> {:ok, result}
        end
    end
  end

end
