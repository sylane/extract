defmodule Test do

  use Extract.BasicTypes


  def test() do
    # v = nil
    # f = :float
    # t = :boolean
    Extract.distill("-0.1779199216902212", :string, :float, [])
  end

end