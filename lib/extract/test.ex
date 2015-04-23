defmodule Test do

  use Extract.BasicTypes


  @allowed_list [3, 4, 5]
  @allowed_map %{3 => :a, 4 => :b, 5 => :c}



  def test() do
    v = 3
    Extract.validate!(v, :integer)
  end

end