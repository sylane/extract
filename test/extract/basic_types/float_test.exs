defmodule Extract.BasicTypes.FloatTest do

  use TestHelper

  @tag timeout: 60000

  test "undefined float" do
    assert_invalid {:undefined_value, :float}, nil, :float
    assert_valid nil, nil, :float, optional: true
    assert_valid nil, nil, :float, allow_undefined: true
    assert_valid nil, nil, :float, allow_undefined: true, optional: true
    assert_valid 3.14, nil, :float, default: 3.14
    assert_valid 3.14, nil, :float, default: 3.14, optional: true
  end

  test "float with allowed values" do
    assert_valid 3.14, 3.14, :float, allowed: [3.14, 2.718, 1.414]
    assert_valid 2.718, 2.718, :float, allowed: [3.14, 2.718, 1.414]
    assert_invalid {:value_not_allowed, :float},
      1.303, :float, allowed: [3.14, 2.718, 1.414]
  end

  test "float with allowed values, minumum and maximum" do
    assert_invalid {:bad_value, {:float, :too_big}},
      3.14, :float, min: 1.4, max: 3.1, allowed: [3.14, 2.718, 1.303]
    assert_valid 2.718,
      2.718, :float, min: 1.4, max: 3.1, allowed: [3.14, 2.718, 1.303]
    assert_invalid {:bad_value, {:float, :too_small}},
      1.303, :float, min: 1.4, max: 3.1, allowed: [3.14, 2.718, 1.303]
    assert_invalid {:value_not_allowed, :float},
      1.414, :float, min: 1.4, max: 3.1, allowed: [3.14, 2.718, 1.303]
  end

  property "valid float" do
    for_all x in real do
      assert_valid ^x, x, :float
    end
  end

  property "valid float with minimum" do
    for_all x in real do
      implies x >= 0 do
        assert_valid ^x, x, :float, min: 0
      end
    end
  end

  property "valid float with maximum" do
    for_all x in real do
      implies x <= 0 do
        assert_valid ^x, x, :float, max: 0
      end
    end
  end

  property "valid float with minimum and maximum" do
    for_all x in real do
      implies x >= -10 and x <= 10 do
        assert_valid ^x, x, :float, min: -10, max: 10
      end
    end
  end

  property "invalid float" do
    for_all x in simpler_any do
      implies not is_float(x) and x != nil do
        assert_invalid {:bad_value, {:float, :bad_type}}, x, :float
      end
    end
  end

  property "too big float" do
    for_all x in real do
      implies x > 0 do
        assert_invalid {:bad_value, {:float, :too_big}}, x, :float, max: 0
      end
    end
  end

  property "too small float" do
    for_all x in real do
      implies x < 0 do
        assert_invalid {:bad_value, {:float, :too_small}},
          x, :float, min: 0
      end
    end
  end

  property "too small or too big float" do
    for_all x in real do
      implies x < -10 or x > 10 do
        assert_invalid({:bad_value, {:float, _}},
          x, :float, min: -10, max: 10)
      end
    end
  end

  test "undefined to float" do
    extracts = Extract.BasicTypes.extracts()
    receipts = Extract.BasicTypes.receipts()
    assert_distill_error {:undefined_value, :float}, nil, :undefined, :float
    for x <- extracts, x != :undefined, {x, :float} in receipts do
      assert_distill_error {:undefined_value, ^x}, nil, x, :float
    end
    for x <- extracts, {x, :float} in receipts do
      assert_distilled nil, nil, x, :float, optional: true
    end
    for x <- extracts, {x, :float} in receipts do
      assert_distilled nil, nil, x, :float, allow_undefined: true
    end
    for x <- extracts, {x, :float} in receipts do
      assert_distilled 3.14, nil, x, :float, default: 3.14
    end
  end

  test "bad float receipts" do
    for {f, v} <- [atom: :foo, boolean: true, binary: "3.14"] do
      assert_distill_error {:bad_receipt, {^f, :float}}, v, f, :float
    end
  end

  property "integer to float" do
    for_all x in int do
      f = x / 1
      assert_distilled ^f, x, :integer, :float
    end
  end

  property "float to float" do
    for_all x in real do
      assert_distilled ^x, x, :float, :float
    end
  end

  property "number to float" do
    for_all x in number do
      f = x / 1
      assert_distilled ^f, x, :number, :float
    end
  end

  property "good string to float" do
    for_all x in real do
      {expected, ""} = Float.parse(to_string(x))
      assert_distilled ^expected, to_string(x), :string, :float
    end
  end

  property "bad string to float" do
    for_all x in unicode_binary do
      implies String.valid?(x) and not is_string_float(x) do
        assert_distill_error {:distillation_error, {:string, :float}},
                             x, :string, :float
      end
    end
  end

  test "convert to allowed float" do
    assert_distilled 3.14, "3.14", :string, :float, allowed: [3.14, 2.718]
    assert_distilled 2.718, 2.718, :float, :float, allowed: [3.14, 2.718]
    assert_distill_error {:value_not_allowed, :float},
      2, :integer, :float, allowed: [3.14, 2.718]
  end


  defp is_string_float(str) do
    case Float.parse(str) do
      {_, ""} -> true
      _ -> false
    end
  end

end
