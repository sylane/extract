defmodule Extract.BasicTypes.IntegerTest do

  use ExUnit.Case, async: false
  use ExCheck

  require TestCompiler
  import TestCompiler, only: :macros


  @allowed [-10, -5, 0, 5, 10]


  property "validate integer" do
    for_all x in int(-200, 200) do
      assert_valid x, x, :integer
    end
  end

  property "validate integer with minimum" do
    for_all x in int(-100, 200) do
      assert_valid x, x, :integer, min: -100
    end
  end

  property "validate integer with maximum" do
    for_all x in int(-200, 100) do
      assert_valid x, x, :integer, max: 100
    end
  end

  property "validate integer with minimum and maximum" do
    for_all x in int(-100, 100) do
      assert_valid x, x, :integer, min: -100, max: 100
    end
  end

  property "validate integer with allowed values" do
    for_all x in int(-10, 10) do
      implies x in @allowed do
        assert_valid x, x, :integer, allowed: @allowed
      end
    end
  end

  property "validate integer with allowed values, minumum and maximum" do
    for_all x in int(-10, 10) do
      implies x in @allowed do
        implies x in @allowed do
          assert_valid x, x, :integer, allowed: @allowed, min: -100, max: 100
        end
      end
    end
  end


  defp assert_valid(expected, val, fmt, opts \\ []) do
    assert {:ok, expected} == execute(
      Extract.BasicTypes.validate(static: val, static: fmt, attribute_kw: opts))
    assert {:ok, expected} == execute(
      Extract.BasicTypes.validate(static: val, static: fmt, static_kw: opts))
    assert {:ok, expected} == execute(
      Extract.BasicTypes.validate(dynamic: val, static: fmt, static_kw: opts))
    assert {:ok, expected} == execute(
      Extract.BasicTypes.validate(static: val, dynamic: fmt, static_kw: opts))
    assert {:ok, expected} == execute(
      Extract.BasicTypes.validate(dynamic: val, dynamic: fmt, static_kw: opts))
    assert expected == execute(
      Extract.BasicTypes.validate!(static: val, static: fmt, attribute_kw: opts))
    assert expected == execute(
      Extract.BasicTypes.validate!(static: val, static: fmt, static_kw: opts))
    assert expected == execute(
      Extract.BasicTypes.validate!(dynamic: val, static: fmt, static_kw: opts))
    assert expected == execute(
      Extract.BasicTypes.validate!(static: val, dynamic: fmt, static_kw: opts))
    assert expected == execute(
      Extract.BasicTypes.validate!(dynamic: val, dynamic: fmt, static_kw: opts))
  end

end
