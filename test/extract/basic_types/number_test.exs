defmodule Extract.BasicTypes.NumberTest do

  use TestHelper

  @tag timeout: 60000


  test "undefined number" do
    assert_invalid {:undefined_value, :number}, nil, :number
    assert_valid nil, nil, :number, optional: true
    assert_valid nil, nil, :number, allow_undefined: true
    assert_valid nil, nil, :number, allow_undefined: true, optional: true
    assert_valid 3.14, nil, :number, default: 3.14
    assert_valid 42, nil, :number, default: 42, optional: true
  end

  test "number with allowed values" do
    assert_valid 3.14, 3.14, :number, allowed: [3.14, 2, 1.414]
    assert_valid 2, 2, :number, allowed: [3.14, 2, 1.414]
    assert_invalid {:value_not_allowed, :number},
      1.303, :number, allowed: [3.14, 2, 1.414]
    assert_invalid {:value_not_allowed, :number},
      3, :number, allowed: [3.14, 2, 1.414]
  end

  test "number with allowed values, minumum and maximum" do
    assert_invalid {:bad_value, {:number, :too_big}},
      3.14, :number, min: 1.4, max: 3.1, allowed: [3.14, 2, 1.303]
    assert_valid 2,
      2, :number, min: 1.4, max: 3.1, allowed: [3.14, 2, 1.303]
    assert_invalid {:bad_value, {:number, :too_small}},
      1.303, :number, min: 1.4, max: 3.1, allowed: [3.14, 2, 1.303]
    assert_invalid {:value_not_allowed, :number},
      1.414, :number, min: 1.4, max: 3.1, allowed: [3.14, 2, 1.303]
  end

  property "valid number" do
    for_all x in number do
      assert_valid ^x, x, :number
    end
  end

  property "valid number with minimum" do
    for_all x in number do
      implies x >= 0 do
        assert_valid ^x, x, :number, min: 0
      end
    end
  end

  property "valid number with maximum" do
    for_all x in number do
      implies x <= 0 do
        assert_valid ^x, x, :number, max: 0
      end
    end
  end

  property "valid number with minimum and maximum" do
    for_all x in number do
      implies x >= -10 and x <= 10 do
        assert_valid ^x, x, :number, min: -10, max: 10
      end
    end
  end

  property "invalid number" do
    for_all x in simpler_any do
      implies not is_number(x) and x != nil do
        assert_invalid {:bad_value, {:number, :bad_type}}, x, :number
      end
    end
  end

  property "too big number" do
    for_all x in number do
      implies x > 0 do
        assert_invalid {:bad_value, {:number, :too_big}}, x, :number, max: 0
      end
    end
  end

  property "too small number" do
    for_all x in number do
      implies x < 0 do
        assert_invalid {:bad_value, {:number, :too_small}},
          x, :number, min: 0
      end
    end
  end

  property "too small or too big number" do
    for_all x in number do
      implies x < -10 or x > 10 do
        assert_invalid({:bad_value, {:number, _}},
          x, :number, min: -10, max: 10)
      end
    end
  end

  test "undefined to number" do
    extracts = Extract.BasicTypes.extracts()
    receipts = Extract.BasicTypes.receipts()
    assert_distill_error {:undefined_value, :number}, nil, :undefined, :number
    for x <- extracts, x != :undefined, {x, :number} in receipts do
      assert_distill_error {:undefined_value, ^x}, nil, x, :number
    end
    for x <- extracts, {x, :number} in receipts do
      assert_distilled nil, nil, x, :number, optional: true
    end
    for x <- extracts, {x, :number} in receipts do
      assert_distilled nil, nil, x, :number, allow_undefined: true
    end
    for x <- extracts, {x, :number} in receipts do
      assert_distilled 42, nil, x, :number, default: 42
    end
  end

  test "bad number receipts" do
    for {f, v} <- [atom: :foo, boolean: true, binary: "3.14"] do
      assert_distill_error {:bad_receipt, {^f, :number}}, v, f, :number
    end
  end

  property "integer to number" do
    for_all x in int do
      assert_distilled ^x, x, :integer, :number
    end
  end

  property "number to number" do
    for_all x in number do
      assert_distilled ^x, x, :number, :number
    end
  end

  property "float to number" do
    for_all x in real do
      assert_distilled ^x, x, :number, :number
    end
  end

  property "good string to number" do
    for_all x in number do
      expected = to_number(to_string(x))
      assert_distilled ^expected, to_string(x), :string, :number
    end
  end

  property "bad string to number" do
    for_all x in unicode_binary do
      implies String.valid?(x) and not is_string_number(x) do
        assert_distill_error {:distillation_error, {:string, :number}},
          x, :string, :number
      end
    end
  end

  test "convert to allowed number" do
    assert_distilled 3.14, "3.14", :string, :number, allowed: [3.14, 42]
    assert_distilled 42, "42", :string, :number, allowed: [3.14, 42]
    assert_distill_error {:value_not_allowed, :number},
      2, :integer, :number, allowed: [3.14, 42]
  end


  defp is_string_number(str) do
    case Integer.parse(str) do
      {_, ""} -> true
      _ ->
        case Float.parse(str) do
          {_, ""} -> true
          _ -> false
        end
    end
  end

  defp to_number(str) do
    case Integer.parse(str) do
      {f, ""} -> f
      _ ->
        case Float.parse(str) do
          {i, ""} -> i
        end
    end
  end

end
