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

  test "undefined to boolean" do
    extracts = Extract.BasicTypes.extracts()
    receipts = Extract.BasicTypes.receipts()
    assert_distill_error {:undefined_value, :boolean},
      nil, :undefined, :boolean
    for x <- extracts, x != :undefined, {x, :boolean} in receipts do
      assert_distill_error {:undefined_value, ^x}, nil, x, :boolean
    end
    for x <- extracts, {x, :boolean} in receipts do
      assert_distilled nil, nil, x, :boolean, optional: true
    end
    for x <- extracts, {x, :boolean} in receipts do
      assert_distilled nil, nil, x, :boolean, allow_undefined: true
    end
    for x <- extracts, {x, :boolean} in receipts do
      assert_distilled true, nil, x, :boolean, default: true
    end
  end

  test "good boolean distillation" do
    for {f, v, x} <- [{:boolean, true, true},
                      {:boolean, false, false},
                      {:atom, true, true},
                      {:atom, false, false},
                      {:string, "true", true},
                      {:string, "false", false}] do
      assert_distilled ^x, v, f, :boolean
    end
  end

  test "bad boolean distillation" do
    for {f, v, x}
      <- [{:atom, :foo, {:distillation_error, {:atom, :boolean}}},
          {:integer, 42, {:bad_receipt, {:integer, :boolean}}},
          {:float, 3.14, {:bad_receipt, {:float, :boolean}}},
          {:number, 42, {:bad_receipt, {:number, :boolean}}},
          {:number, 3.14, {:bad_receipt, {:number, :boolean}}},
          {:string, "foo", {:distillation_error, {:string, :boolean}}},
          {:binary, "foo", {:bad_receipt, {:binary, :boolean}}}] do
      assert_distill_error ^x, v, f, :boolean
    end
  end

  test "good allowed boolean distillation" do
    for {f, v, x} <- [{:boolean, true, true},
                      {:atom, true, true},
                      {:string, "true", true}] do
      assert_distilled ^x, v, f, :boolean, allowed: [true]
    end
  end

  test "good but not allowed boolean distillation" do
    for {f, v} <- [{:boolean, false}, {:atom, false}, {:string, "false"}] do
      assert_distill_error {:value_not_allowed, :boolean},
                           v, f, :boolean, allowed: [true]
    end
  end

end
