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
    assert_distill_error {:undefined_value, :atom}, nil, :undefined, :atom
    assert_distilled nil, nil, :undefined, :atom, optional: true
    assert_distilled nil, nil, :undefined, :atom, allow_undefined: true
    assert_distilled :foo, nil, :undefined, :atom, default: :foo
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
  end

  test "integer to atom" do
    assert_distill_error {:bad_receipt, {:integer, :atom}}, 42, :integer, :atom
  end

  test "float to atom" do
    assert_distill_error {:bad_receipt, {:float, :atom}}, 3.14, :float, :atom
  end

  test "number to atom" do
    assert_distill_error {:bad_receipt, {:number, :atom}}, 42, :number, :atom
    assert_distill_error {:bad_receipt, {:number, :atom}}, 3.14, :number, :atom
  end

  test "string to atom" do
    assert_distilled :foo, "foo", :string, :atom
    assert_distilled :">6ZX:7IYxhhG", ">6ZX:7IYxhhG", :string, :atom
    assert_distill_error {:value_not_allowed, :atom},
      "string that do not exists as an atom", :string, :atom
  end

  test "binary to atom" do
    assert_distilled :foo, <<"foo">>, :binary, :atom
    assert_distilled :">6ZX:7IYxhhG", <<">6ZX:7IYxhhG">>, :string, :atom
    assert_distill_error {:value_not_allowed, :atom},
      <<"binary that do not exists as an atom">>, :string, :atom
  end

  test "convert to allowed atom" do
    assert_distilled :foo, "foo", :string, :atom, allowed: [:foo, :bar]
    assert_distilled :bar, :bar, :atom, :atom, allowed: [:foo, :bar]
    assert :buz == String.to_atom("buz") # so the atom exists in the atom table
    assert_distill_error {:value_not_allowed, :atom},
      "buz", :string, :atom, allowed: [:foo, :bar]
  end

end
