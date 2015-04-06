defmodule Extract.Types do

  alias Extract.Meta
  alias Extract.Meta.Context

  alias Extract.Types


  defmacro condence(value, _from, _to, _opts \\ []) do
    value
    |> Context.start(env: __ENV__, caller: __CALLER__)
    |> Context.terminate
    # |> Context.debug
  end


  defmacro condence!(value, _from, _to, _opts \\ []) do
    value
    |> Context.start(env: __ENV__, caller: __CALLER__)
    |> Context.terminate!
    # |> Context.debug
  end


  defmacro validate(value, format, opts \\ []) do
    value
    |> Context.start(env: __ENV__, caller: __CALLER__)
    |> Meta.check_undefined
    |> Meta.check_default do
    |> _meta_validate(format, opts)
    |> Context.terminate debug: true
  end


  defmacro validate!(value, format, opts \\ []) do
    value
    |> Context.start(env: __ENV__, caller: __CALLER__)
    |> _meta_validate(format, opts)
    |> Context.terminate!
    # |> Context.debug
  end


  def _meta_types() do
    [:undefined,
     :atom, :boolean,
     :integer, :float,
     :string, :binary,
     :list, :tuple,
     :map, :struct]
  end


  def _meta_validate({_, context} = param, format, opts) do
    Extract.Meta.branch context, format,
      undefined: _meta_validate_dummy(param, opts),
      atom:      _meta_validate_dummy(param, opts),
      boolean:   _meta_validate_dummy(param, opts),
      integer:   Types.Integer.validate(param, opts),
      float:     _meta_validate_dummy(param, opts),
      string:    _meta_validate_dummy(param, opts),
      binary:    _meta_validate_dummy(param, opts),
      list:      _meta_validate_dummy(param, opts),
      tuple:     _meta_validate_dummy(param, opts),
      map:       _meta_validate_dummy(param, opts),
      struct:    _meta_validate_dummy(param, opts)
  end


  def _meta_validate_dummy(param, _opts), do: param

end