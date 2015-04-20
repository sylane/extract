defmodule Extract.BasicTypes.FloatTest do

  use TestHelper


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

  @tag timeout: 60000
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

  # test "undefined to float" do
  #   assert_distill_error {:undefined_value, :float}, nil, :undefined, :float
  #   assert_distilled nil, nil, :undefined, :float, optional: true
  #   assert_distilled nil, nil, :undefined, :float, allow_undefined: true
  #   assert_distilled 3.14, nil, :undefined, :float, default: 3.14
  # end

  # test "atom to float" do
  #   assert_distill_error {:bad_receipt, {:atom, :float}},
  #     :"3.14", :atom, :float
  # end

  # test "boolean to float" do
  #   assert_distill_error {:bad_receipt, {:boolean, :float}},
  #     false, :boolean, :float
  # end

  # @tag timeout: 60000
  # property "integer to float" do
  #   for_all x in int do
  #     f = x / 1
  #     assert_distilled ^f, x, :integer, :float
  #   end
  # end

  # @tag timeout: 60000
  # test "float to float" do
  #   for_all x in real do
  #     assert_distilled ^x, x, :float, :float
  #   end
  # end

  # @tag timeout: 60000
  # property "number to float" do
  #   for_all x in number do
  #     f = x /1
  #     assert_distilled ^f, x, :number, :float
  #   end
  # end

  # @tag timeout: 60000
  # property "good string to float" do
  #   for_all x in real do
  #     assert_distilled ^x, to_string(x), :string, :float
  #   end
  # end

  # @tag timeout: 60000
  # property "bad string to float" do
  #   for_all x in unicode_binary do
  #     implies not is_string_float(x) do
  #       assert_distill_error {:distillation_error, {:string, :float}},
  #         x, :string, :float
  #     end
  #   end
  # end

  # @tag timeout: 60000
  # property "good binary to float" do
  #   for_all x in real do
  #     assert_distilled ^x, to_string(x), :binary, :float
  #   end
  # end

  # @tag timeout: 60000
  # property "bad binary to float" do
  #   for_all x in binary do
  #     implies not is_string_float(x) do
  #       assert_distill_error {:distillation_error, {:binary, :float}},
  #         x, :binary, :float
  #     end
  #   end
  # end

  # test "convert to allowed float" do
  #   assert_distilled 3.14, "3.14", :string, :float, allowed: [3.14, 2.718]
  #   assert_distilled 2.718, 2.718, :float, :float, allowed: [3.14, 2.718]
  #   assert_distill_error {:value_not_allowed, :float},
  #     2, :integer, :float, allowed: [3.14, 2.718]
  # end


  # defp is_string_float(str) do
  #   try do
  #     is_float(String.to_float(str))
  #   rescue
  #     ArgumentError -> false
  #   end
  # end

end
