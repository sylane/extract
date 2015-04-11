defmodule Test do

  use Extract.Types


  def test(value, format) do
    Extract.Types.validate(value, format)
  end

  # def test(value, format) do
  #   Extract.Types.validate(value, format, optional: true)
  # end

  # def test(value, format) do
  #   Extract.Types.validate(value, format, default: 42)
  # end

  # def test(value) do
  #   Extract.Types.validate(value, :integer)
  # end

  # def test(value) do
  #   Extract.Types.validate(value, :integer, optional: true)
  # end

  # def test(value) do
  #   Extract.Types.validate(value, :integer, default: 33)
  # end

  # def test(format) do
  #   Extract.Types.validate(3, format)
  # end

  # def test(format) do
  #   Extract.Types.validate(nil, format, default: 42)
  # end

  # def test() do
  #   Extract.Types.validate(3, :integer)
  # end

  # def test() do
  #   Extract.Types.validate(nil, :integer)
  # end

  # def test() do
  #   Extract.Types.validate(nil, :integer, default: 44)
  # end

  # def test() do
  #   Extract.Types.validate(3, :foo)
  # end

end