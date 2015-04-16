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

end
