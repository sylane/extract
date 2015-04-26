defmodule Test do

  use Extract.BasicTypes


  @allowed_list [3, 4, 5]
  @allowed_map %{3 => :a, 4 => :b, 5 => :c}



  def test(v, from, to) do
    # v = 3.4
    # from = :float
    # to = :integer
    # Extract.validate(v, from)
    Extract.distill!(nil, from, to, optional: true)
  end

end