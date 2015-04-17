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

  test "convert to undefined" do
    assert_distilled nil, nil, :undefined, :undefined
    assert_distilled nil, nil, :atom, :undefined
    assert_distilled nil, nil, :boolean, :undefined
    assert_distilled nil, nil, :integer, :undefined
    assert_distilled nil, nil, :float, :undefined
    assert_distilled nil, nil, :number, :undefined
    assert_distilled nil, nil, :string, :undefined
    assert_distilled nil, nil, :binary, :undefined
    assert_distill_error {:bad_value, {:undefined, :bad_type}},
      :foo, :atom, :undefined
    assert_distill_error {:bad_value, {:undefined, :bad_type}},
      false, :boolean, :undefined
    assert_distill_error {:bad_value, {:undefined, :bad_type}},
      42, :integer, :undefined
    assert_distill_error {:bad_value, {:undefined, :bad_type}},
      3.14, :float, :undefined
    assert_distill_error {:bad_value, {:undefined, :bad_type}},
      42, :number, :undefined
    assert_distill_error {:bad_value, {:undefined, :bad_type}},
      3.14, :number, :undefined
    assert_distill_error {:bad_value, {:undefined, :bad_type}},
      "foo", :string, :undefined
    assert_distill_error {:bad_value, {:undefined, :bad_type}},
      <<1, 2, 3>>, :binary, :undefined
  end

end
