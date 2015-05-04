defmodule Extract.BasicTypes.StringTest do

  use TestHelper

  @tag timeout: 60000


  test "undefined string" do
    assert_invalid {:undefined_value, :string}, nil, :string
    assert_valid nil, nil, :string, optional: true
    assert_valid nil, nil, :string, allow_undefined: true
    assert_valid nil, nil, :string, allow_undefined: true, optional: true
    assert_valid "foo", nil, :string, default: "foo"
    assert_valid "bar", nil, :string, default: "bar", optional: true
  end

  test "valid string with allowed values" do
    assert_valid "foo", "foo", :string, allowed: ["foo", "bar"]
    assert_valid "bar", "bar", :string, allowed: ["foo", "bar"]
    assert_invalid {:value_not_allowed, :string},
      "buz", :string, allowed: ["foo", "bar"]
  end

  test "valid unicode sequence" do
    # Valid ASCII
    assert_valid <<0x61>>, <<0x61>>, :string
    # Valid 2 bytes sequence
    assert_valid <<0xc3,0xb1>>, <<0xc3,0xb1>>, :string
    # Valid 3 bytes sequence
    assert_valid <<0xe2,0x82,0xa1>>, <<0xe2,0x82,0xa1>>, :string
    # Valid 4 bytes sequence
    assert_valid <<0xf0,0x90,0x8c,0xbc>>, <<0xf0,0x90,0x8c,0xbc>>, :string
  end

  test "invalid unicode sequence" do
    # Invalid 2 bytes sequence
    assert_invalid {:bad_value, {:string, :bad_type}},
      <<0xc3,0x28>>, :string
    # Invalid sequence Identifier
    assert_invalid {:bad_value, {:string, :bad_type}},
      <<0xa0,0xa1>>, :string
    # Invalid 3 bytes sequence (in 2nd byte)
    assert_invalid {:bad_value, {:string, :bad_type}},
      <<0xe2,0x28,0xa1>>, :string
    # Invalid 3 bytes sequence (in 3rd byte)
    assert_invalid {:bad_value, {:string, :bad_type}},
      <<0xe2,0x82,0x28>>, :string
    # Invalid 4 bytes sequence (in 2nd byte)
    assert_invalid {:bad_value, {:string, :bad_type}},
      <<0xf0,0x28,0x8c,0xbc>>, :string
    # Invalid 4 bytes sequence (in 3rd byte)
    assert_invalid {:bad_value, {:string, :bad_type}},
      <<0xf0,0x90,0x28,0xbc>>, :string
    # Invalid 4 bytes sequence (in 4th byte)
    assert_invalid {:bad_value, {:string, :bad_type}},
      <<0xf0,0x28,0x8c,0x28>>, :string
    # Valid 5 bytes sequence (but not Unicode!)
    assert_invalid {:bad_value, {:string, :bad_type}},
      <<0xf8,0xa1,0xa1,0xa1,0xa1>>, :string
    # Valid 6 bytes sequence (but not Unicode!)
    assert_invalid {:bad_value, {:string, :bad_type}},
      <<0xfc,0xa1,0xa1,0xa1,0xa1,0xa1>>, :string
  end

  property "valid string" do
    for_all x in unicode_binary do
      implies String.valid?(x) do
        assert_valid ^x, x, :string
      end
    end
  end

  property "invalid string" do
    for_all x in simpler_any do
      implies not is_binary(x) and x != nil do
        assert_invalid {:bad_value, {:string, :bad_type}}, x, :string
      end
    end
  end

  test "undefined to string" do
    extracts = Extract.BasicTypes.extracts()
    receipts = Extract.BasicTypes.receipts()
    assert_distill_error {:undefined_value, :string}, nil, :undefined, :string
    for x <- extracts, x != :undefined, {x, :string} in receipts do
      assert_distill_error {:undefined_value, ^x}, nil, x, :string
    end
    for x <- extracts, {x, :string} in receipts do
      assert_distilled nil, nil, x, :string, optional: true
    end
    for x <- extracts, {x, :string} in receipts do
      assert_distilled nil, nil, x, :string, allow_undefined: true
    end
    for x <- extracts, {x, :string} in receipts do
      assert_distilled 42, nil, x, :string, default: 42
    end
  end

  property "atom to string" do
    for_all x in atom do
      implies x != nil do
        s = Atom.to_string(x)
        assert_distilled ^s, x, :atom, :string
      end
    end
  end

  test "boolean to string" do
    assert_distilled "true", true, :boolean, :string
    assert_distilled "false", false, :boolean, :string
  end

  property "integer to string" do
    for_all x in int do
      s = to_string(x)
      assert_distilled ^s, x, :integer, :string
    end
  end

  property "float to string" do
    for_all x in real do
      s = to_string(x)
      assert_distilled ^s, x, :float, :string
    end
  end

  property "number to string" do
    for_all x in number do
      s = to_string(x)
      assert_distilled ^s, x, :number, :string
    end
  end

  test "binary/string to string" do
    assert_distilled "foo", "foo", :string, :string
    assert_distilled "foo", "foo", :binary, :string
  end

  test "convert to allowed string" do
    assert_distilled "42", 42, :integer, :string, allowed: ["42", "3.14"]
    assert_distilled "3.14", 3.14, :float, :string, allowed: ["42", "3.14"]
    assert_distill_error {:value_not_allowed, :string},
      33, :integer, :string, allowed: ["42", "3.14"]
  end

end
