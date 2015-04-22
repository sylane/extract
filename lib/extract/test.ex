defmodule Test do

  use Extract.BasicTypes
  # alias Extract.BasicTypes


  @allowed_list [3, 4, 5]
  @allowed_map %{3 => :a, 4 => :b, 5 => :c}


  # def test(value, from, to) do
  #   Extract.Types.distill value, from, to
  # end

  # def test() do
  #   v = 3.14
  #   f = :float
  #   t = :integer
  #   BasicTypes._distill(v, f, t)
  # end

  def test() do
    v = 3
    f = :integer
    # Extract.validate!(3, :integer)
    # Extract.validate!(nil, :integer)
    # Extract.validate!(3, :integer)
    # Extract.validate!(3, :foo)
    # Extract.validate!(3, f)
    Extract.validate!(v, :integer)
    # Extract.validate!(v, f)
  end

  # def test(value, format) do
  #   BasicTypes.validate value, format
  # end

  # def test(value, format) do
  #   BasicTypes.validate(value, format, min: 3, max: 10, optional: true)
  # end

  # def test(value, format) do
  #   BasicTypes.validate(value, format, allowed: [3, 4, 5])
  # end

  # def test(value, format) do
  #   BasicTypes.validate(value, format, allowed: @allowed)
  # end

  # def test(value, format) do
  #   BasicTypes.validate(value, format, optional: true)
  # end

  # def test(value, format) do
  #   BasicTypes.validate(value, format, default: 42)
  # end

  # def test(value) do
  #   BasicTypes.validate(value, :integer, allowed: @allowed_list, optional: true)
  # end

  # def test(value) do
  #   BasicTypes.validate(value, :integer, optional: true)
  # end

  # def test(value) do
  #   BasicTypes.validate(value, :integer, default: 33)
  # end

  # def test(value) do
  #   BasicTypes.validate(value, :integer, default: 33, allowed: [3, 4, 5])
  # end

  # def test(format) do
  #   BasicTypes.validate(3, format)
  # end

  # def test(format) do
  #   BasicTypes.validate(nil, format, default: 42)
  # end

  # def test() do
  #   BasicTypes.validate(3, :number)
  # end

  # def test() do
  #   BasicTypes.validate(3, :integer, allowed: @allowed_map)
  # end

  # def test() do
  #   BasicTypes.validate(nil, :integer)
  # end

  # def test() do
  #   BasicTypes.validate(nil, :integer, default: 44)
  # end

  # def test() do
  #   BasicTypes.validate(3, :foo)
  # end

end