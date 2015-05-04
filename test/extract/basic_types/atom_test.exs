defmodule Extract.BasicTypes.AtomTest do

  use TestHelper


  test "undefined atom" do
    assert_invalid {:undefined_value, :atom}, nil, :atom
    assert_valid nil, nil, :atom, optional: true
    assert_valid nil, nil, :atom, allow_undefined: true
    assert_valid nil, nil, :atom, allow_undefined: true, optional: true
    assert_valid :foo, nil, :atom, default: :foo
    assert_valid :bar, nil, :atom, default: :bar, optional: true
  end

  test "valid atom with allowed values" do
    assert_valid :foo, :foo, :atom, allowed: [:foo, :bar]
    assert_valid :bar, :bar, :atom, allowed: [:foo, :bar]
    assert_invalid {:value_not_allowed, :atom},
      :buz, :atom, allowed: [:foo, :bar]
  end

  test "special atom values" do
    assert_valid true, true, :atom
    assert_valid false, false, :atom
  end

  property "valid atom" do
    for_all x in atom do
      implies x != nil do
        assert_valid ^x, x, :atom
      end
    end
  end

  property "invalid atom" do
    for_all x in simpler_any do
      implies not is_atom(x) do
        assert_invalid {:bad_value, {:atom, :bad_type}}, x, :atom
      end
    end
  end

  test "undefined to atom" do
    extracts = Extract.BasicTypes.extracts()
    receipts = Extract.BasicTypes.receipts()
    assert_distill_error {:undefined_value, :atom}, nil, :undefined, :atom
    for x <- extracts, x != :undefined, {x, :atom} in receipts do
      assert_distill_error {:undefined_value, ^x}, nil, x, :atom
    end
    for x <- extracts, {x, :atom} in receipts do
      assert_distilled nil, nil, x, :atom, optional: true
    end
    for x <- extracts, {x, :atom} in receipts do
      assert_distilled nil, nil, x, :atom, allow_undefined: true
    end
    for x <- extracts, {x, :atom} in receipts do
      assert_distilled :foo, nil, x, :atom, default: :foo
    end
  end

  test "bad atom receipts" do
    for {f, v} <- [integer: 42, float: 3.14, number: 33, number: 3.33e33] do
      assert_distill_error {:bad_receipt, {^f, :atom}}, v, f, :atom
    end
  end

  property "atom to atom" do
    for_all x in atom do
      implies x != nil do
        assert_distilled ^x, x, :atom, :atom
      end
    end
  end

  test "boolean to atom" do
    assert_distilled true, true, :boolean, :atom
    assert_distilled false, false, :boolean, :atom
    for bad <- [:foo, 42, 3.14, "bad"] do
      assert_distill_error {:bad_value, {:boolean, :bad_type}},
                           bad, :boolean, :atom
    end
  end

  test "string to atom" do
    for {val, res} <- [{"foo", :foo}, {">6ZX:7IYxhhG", :">6ZX:7IYxhhG"}] do
      assert_distilled ^res, val, :string, :atom
    end
    assert_distill_error {:value_not_allowed, :string},
      "string that do not exists as an atom", :string, :atom
    for bad <- [:foo, true, 42, 3.14] do
      assert_distill_error {:bad_value, {:string, :bad_type}},
                           bad, :string, :atom
    end
  end

  test "convert to allowed atom" do
    assert_distilled :foo, "foo", :string, :atom, allowed: [:foo, :bar]
    assert_distilled :bar, :bar, :atom, :atom, allowed: [:foo, :bar]
    assert :buz == String.to_atom("buz") # so the atom exists in the atom table
    assert_distill_error {:value_not_allowed, :atom},
      "buz", :string, :atom, allowed: [:foo, :bar]
  end

end
