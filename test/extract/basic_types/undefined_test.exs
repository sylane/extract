defmodule Extract.BasicTypes.UndefinedTest do

  use TestHelper


  test "valid undefined" do
    assert_valid nil, nil, :undefined
  end

  @tag timeout: 60000
  property "invalid undefined" do
    for_all x in simpler_any do
      implies x != nil do
        assert_invalid {:bad_value, {:undefined, :bad_type}}, x, :undefined
      end
    end
  end


end
