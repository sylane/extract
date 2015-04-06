defmodule Extract.Types.Integer do

  require Extract.Meta.Options

  alias Extract.Meta.Options


  def validate({:undefined, context} = param, opts) do
    %%%%%%% default value ?
    case Options.allow_undefined(opts) do
      true -> param
      false ->
        raise ExtractError,
          reason: value_not_defined,
          message: "integer value not defined",
          context: context
    end
  end

  def validate({:missing, context} = param, opts) do
    %%%%%%% default value ?
    case Options.allow_missing(opts) do
      true -> param
      false ->
        raise ExtractError,
          reason: missing_value,
          message: "missing integer value",
          context: context
    end
  end

  def validate({{:value, value}, _context} = param, _opts)
   when is_integer(value), do: param

  def validate(param, _opts) do

  end

end