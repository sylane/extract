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
    for_all x in any do
      implies not is_float(x) do
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

end
