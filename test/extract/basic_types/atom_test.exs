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

  test "invalid special atom values" do
    assert_invalid {:bad_value, {:atom, :bad_type}}, true, :atom
    assert_invalid {:bad_value, {:atom, :bad_type}}, false, :atom
  end

  property "valid atom" do
    for_all x in atom do
      implies not x in [nil, true, false] do
        assert_valid ^x, x, :atom
      end
    end
  end

  @tag timeout: 60000
  property "invalid atom" do
    for_all x in any do
      implies not is_atom(x) or x == true or x == false do
        assert_invalid {:bad_value, {:atom, :bad_type}}, x, :atom
      end
    end
  end

end
