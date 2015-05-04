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

  test "undefined to binary" do
    extracts = Extract.BasicTypes.extracts()
    receipts = Extract.BasicTypes.receipts()
    assert_distill_error {:undefined_value, :binary}, nil, :undefined, :binary
    for x <- extracts, x != :undefined, {x, :binary} in receipts do
      assert_distill_error {:undefined_value, ^x}, nil, x, :binary
    end
    for x <- extracts, {x, :binary} in receipts do
      assert_distilled nil, nil, x, :binary, optional: true
    end
    for x <- extracts, {x, :binary} in receipts do
      assert_distilled nil, nil, x, :binary, allow_undefined: true
    end
    for x <- extracts, {x, :binary} in receipts do
      assert_distilled "foo", nil, x, :binary, default: "foo"
    end
  end

  test "bad binary receipts" do
    for {f, v} <- [atom: :foo, boolean: true, integer: 42,
                   float: 3.14, number: 33, number: 3.33e33] do
      assert_distill_error {:bad_receipt, {^f, :binary}}, v, f, :binary
    end
  end

  property "string to binary" do
    for_all x in unicode_binary do
      assert_distilled ^x, x, :string, :binary
    end
  end

  property "binary to binary" do
    for_all x in binary do
      assert_distilled ^x, x, :binary, :binary
    end
  end

  test "convert to allowed binary" do
    assert_distilled "foo", "foo", :string, :binary, allowed: ["foo", "bar"]
    assert_distilled "bar", "bar", :string, :binary, allowed: ["foo", "bar"]
    assert_distill_error {:value_not_allowed, :binary},
      "buz", :string, :binary, allowed: ["foo", "bar"]
  end

end
