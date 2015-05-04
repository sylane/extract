defmodule Extract.BasicTypes.IntegerTest do

  use TestHelper

  @tag timeout: 60000
  @allowed :lists.seq(-200, 200, 5)


  test "undefined integer" do
    assert_invalid {:undefined_value, :integer}, nil, :integer
    assert_valid nil, nil, :integer, optional: true
    assert_valid nil, nil, :integer, allow_undefined: true
    assert_valid nil, nil, :integer, allow_undefined: true, optional: true
    assert_valid 42, nil, :integer, default: 42
    assert_valid 42, nil, :integer, default: 42, optional: true
  end

  property "valid integer" do
    for_all x in int(-200, 200) do
      assert_valid ^x, x, :integer
    end
  end

  property "valid integer with minimum" do
    for_all x in int(-100, 200) do
      assert_valid ^x, x, :integer, min: -100
    end
  end

  property "valid integer with maximum" do
    for_all x in int(-200, 100) do
      assert_valid ^x, x, :integer, max: 100
    end
  end

  property "valid integer with minimum and maximum" do
    for_all x in int(-100, 100) do
      assert_valid ^x, x, :integer, min: -100, max: 100
    end
  end

  property "valid integer with allowed values" do
    for_all x in int(-10, 10) do
      implies x in @allowed do
        assert_valid ^x, x, :integer, allowed: @allowed
      end
    end
  end

  property "valid integer with allowed values, minumum and maximum" do
    for_all x in int(-200, 200) do
      implies x in @allowed do
        implies x >= -100 and x <= 100 do
          assert_valid ^x, x, :integer, allowed: @allowed, min: -100, max: 100
        end
      end
    end
  end

  property "invalid integer" do
    for_all x in simpler_any do
      implies not is_integer(x) and x != nil do
        assert_invalid {:bad_value, {:integer, :bad_type}}, x, :integer
      end
    end
  end

  property "too big integer" do
    for_all x in int(101, 200) do
      assert_invalid {:bad_value, {:integer, :too_big}}, x, :integer, max: 100
    end
  end

  property "too small integer" do
    for_all x in int(-200, -101) do
      assert_invalid {:bad_value, {:integer, :too_small}},
        x, :integer, min: -100
    end
  end

  property "too small or too big integer" do
    for_all x in int(-200, 200) do
      implies x < -100 or x > 100 do
        assert_invalid({:bad_value, {:integer, _}},
          x, :integer, min: -100, max: 100)
      end
    end
  end

  property "not allowed integer" do
    for_all x in int(-200, 200) do
      implies not x in @allowed do
        assert_invalid {:value_not_allowed, :integer},
          x, :integer, allowed: @allowed
      end
    end
  end

  property "not allowed, too big or too small integer" do
    for_all x in int(-200, 200) do
      implies not x in @allowed do
        implies x < -100 or x > 100 do
          assert_invalid {_, _},
            x, :integer, min: -100, max: 100, allowed: @allowed
        end
      end
    end
  end

  test "undefined to integer" do
    extracts = Extract.BasicTypes.extracts()
    receipts = Extract.BasicTypes.receipts()
    assert_distill_error {:undefined_value, :integer}, nil, :undefined, :integer
    for x <- extracts, x != :undefined, {x, :integer} in receipts do
      assert_distill_error {:undefined_value, ^x}, nil, x, :integer
    end
    for x <- extracts, {x, :integer} in receipts do
      assert_distilled nil, nil, x, :integer, optional: true
    end
    for x <- extracts, {x, :integer} in receipts do
      assert_distilled nil, nil, x, :integer, allow_undefined: true
    end
    for x <- extracts, {x, :integer} in receipts do
      assert_distilled 42, nil, x, :integer, default: 42
    end
  end

  test "bad integer receipts" do
    for {f, v} <- [atom: :foo, boolean: true, binary: "42"] do
      assert_distill_error {:bad_receipt, {^f, :integer}}, v, f, :integer
    end
  end

  property "integer to integer" do
    for_all x in int do
      assert_distilled ^x, x, :integer, :integer
    end
  end

  property "float to integer" do
    for_all x in real do
      i = round(x)
      assert_distilled ^i, x, :float, :integer
    end
  end

  property "number to integer" do
    for_all x in number do
      i = round(x)
      assert_distilled ^i, x, :number, :integer
    end
  end

  property "good string to integer" do
    for_all x in int do
      assert_distilled ^x, to_string(x), :string, :integer
    end
  end

  property "bad string to integer" do
    for_all x in unicode_binary do
      implies String.valid?(x) and not is_string_int(x) do
        assert_distill_error {:distillation_error, {:string, :integer}},
          x, :string, :integer
      end
    end
  end

  property "convert to allowed integer" do
    for_all x in int(-200, 200) do
      implies x in @allowed do
        assert_distilled ^x, to_string(x), :string, :integer, allowed: @allowed
        assert_distilled ^x, x / 1, :float, :integer, allowed: @allowed
      end
    end
  end

  property "convert to fobidden integer" do
    for_all x in int(-200, 200) do
      implies not x in @allowed do
        assert_distill_error {:value_not_allowed, :integer},
          to_string(x), :string, :integer, allowed: @allowed
      end
    end
  end

  test "convert to range-limited and allowed integer" do
    assert_distilled 7, "7", :string, :integer,
      min: 7, max: 9, allowed: [5, 6, 7, 9, 10]
    assert_distill_error {:value_not_allowed, :integer},
      "8", :string, :integer, min: 7, max: 9, allowed: [5, 6, 7, 9, 10]
    assert_distill_error {:bad_value, {:integer, :too_small}},
      "5", :string, :integer, min: 7, max: 9, allowed: [5, 6, 7, 9, 10]
    assert_distill_error {:bad_value, {:integer, :too_big}},
      "10", :string, :integer, min: 7, max: 9, allowed: [5, 6, 7, 9, 10]
  end


  defp is_string_int(str) do
    case Integer.parse(str) do
      {_, ""} -> true
      _ -> false
    end
  end

end
