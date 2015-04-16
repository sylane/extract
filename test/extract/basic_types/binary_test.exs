defmodule Extract.BasicTypes.BinaryTest do

  use TestHelper


  test "undefined binary" do
    assert_invalid {:undefined_value, :binary}, nil, :binary
    assert_valid nil, nil, :binary, optional: true
    assert_valid nil, nil, :binary, allow_undefined: true
    assert_valid nil, nil, :binary, allow_undefined: true, optional: true
    assert_valid <<1, 2, 3>>, nil, :binary, default: <<1, 2, 3>>
    assert_valid <<4, 5, 6>>, nil, :binary, default: <<4, 5, 6>>, optional: true
  end

  test "valid binary with allowed values" do
    assert_valid <<1, 2>>, <<1, 2>>, :binary, allowed: [<<1, 2>>, <<2, 3>>]
    assert_valid <<2, 3>>, <<2, 3>>, :binary, allowed: [<<1, 2>>, <<2, 3>>]
    assert_invalid {:value_not_allowed, :binary},
      <<4, 5>>, :binary, allowed: [<<1, 2>>, <<2, 3>>]
  end

  property "valid binary" do
    for_all x in binary do
      assert_valid ^x, x, :binary
    end
  end

  @tag timeout: 60000
  property "invalid binary" do
    for_all x in simpler_any do
      implies not is_binary(x) and x != nil do
        assert_invalid {:bad_value, {:binary, :bad_type}}, x, :binary
      end
    end
  end

end
