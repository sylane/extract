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

  # test "undefined to binary" do
  #   assert_distill_error {:undefined_value, :binary}, nil, :undefined, :binary
  #   assert_distilled nil, nil, :undefined, :binary, optional: true
  #   assert_distilled nil, nil, :undefined, :binary, allow_undefined: true
  #   assert_distilled :foo, nil, :undefined, :binary, default: :foo
  # end

  # property "atom to binary" do
  #   for_all x in atom do
  #     implies x != nil do
  #       s = Atom.to_string(x)
  #       assert_distilled ^s, x, :atom, :binary
  #     end
  #   end
  # end

  # test "boolean to binary" do
  #   assert_distilled <<"true">>, true, :boolean, :binary
  #   assert_distilled <<"false">>, false, :boolean, :binary
  # end

  # property "integer to binary" do
  #   for_all x in int do
  #     s = to_string(x)
  #     assert_distilled ^s, x, :integer, :binary
  #   end
  # end

  # property "float to binary" do
  #   for_all x in real do
  #     s = to_string(x)
  #     assert_distilled ^s, x, :float, :binary
  #   end
  # end

  # property "number to binary" do
  #   for_all x in number do
  #     s = to_string(x)
  #     assert_distilled ^s, x, :number, :binary
  #   end
  # end

  # test "binary/string to binary" do
  #   assert_distilled "foo", "foo", :string, :binary
  #   assert_distilled "foo", "foo", :binary, :binary
  # end

  # test "convert to allowed binary" do
  #   assert_distilled "42", 42, :integer, :binary, allowed: ["42", "3.14"]
  #   assert_distilled "3.14", 3.14, :float, :binary, allowed: ["42", "3.14"]
  #   assert_distill_error {:value_not_allowed, :binary},
  #     33, :integer, :binary, allowed: ["42", "3.14"]
  # end

end
