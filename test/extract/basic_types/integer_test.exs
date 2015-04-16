defmodule Extract.BasicTypes.IntegerTest do

  use TestHelper


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

  @tag timeout: 60000
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

end
