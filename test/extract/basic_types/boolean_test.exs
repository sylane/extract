defmodule Extract.BasicTypes.BooleanTest do

  use TestHelper


  test "undefined boolean" do
    assert_invalid {:undefined_value, :boolean}, nil, :boolean
    assert_valid nil, nil, :boolean, optional: true
    assert_valid nil, nil, :boolean, allow_undefined: true
    assert_valid nil, nil, :boolean, allow_undefined: true, optional: true
    assert_valid false, nil, :boolean, default: false
    assert_valid true, nil, :boolean, default: true, optional: true
  end

  test "valid boolean with allowed values" do
    assert_valid false, false, :boolean, allowed: [false]
    assert_invalid {:value_not_allowed, :boolean},
      true, :boolean, allowed: [false]
  end

  test "valid boolean" do
    assert_valid true, true, :boolean
    assert_valid false, false, :boolean
  end

  @tag timeout: 60000
  property "invalid boolean" do
    for_all x in simpler_any do
      implies not is_boolean(x) and x != nil do
        assert_invalid {:bad_value, {:boolean, :bad_type}}, x, :boolean
      end
    end
  end

  # test "convert to boolean" do
  #   assert_distill_error {:undefined_value, :boolean},
  #     nil, :undefined, :boolean
  #   assert_distilled nil, nil, :undefined, :boolean, optional: true
  #   assert_distilled false, :false, :atom, :boolean
  #   assert_distill_error {:distillation_error, {:atom, :boolean}},
  #     :foo, :atom, :boolean
  #   assert_distilled true, true, :boolean, :boolean
  #   assert_distill_error {:bad_receipt, {:integer, :boolean}},
  #     42, :integer, :boolean
  #   assert_distill_error {:bad_receipt, {:float, :boolean}},
  #     3.14, :float, :boolean
  #   assert_distill_error {:bad_receipt, {:number, :boolean}},
  #     42, :number, :boolean
  #   assert_distill_error {:bad_receipt, {:number, :boolean}},
  #     3.14, :number, :boolean
  #   assert_distilled true, "true", :string, :boolean
  #   assert_distill_error {:distillation_error, {:string, :boolean}},
  #     "foo", :string, :boolean
  #   assert_distilled false, <<"false">>, :binary, :boolean
  #   assert_distill_error {:distillation_error, {:binary, :boolean}},
  #     <<"bar">>, :binary, :boolean
  # end

end
