import Notation

defmodule NotationTest do
  use ExUnit.Case
  doctest Notation

  test "validates unit notations" do
    assert true == Notation.is_unit_notation("0000000")
    assert true == Notation.is_unit_notation("0000950")
    assert true == Notation.is_unit_notation("0022345")
    assert true == Notation.is_unit_notation("1234590")
    assert true == Notation.is_unit_notation("2000000")


    assert false == Notation.is_unit_notation("00002345")
    assert false == Notation.is_unit_notation("0023445567")
    assert false == Notation.is_unit_notation("234")
    assert false == Notation.is_unit_notation("000")
    assert false == Notation.is_unit_notation("0")

    assert false == Notation.is_unit_notation("000000A")
    assert false == Notation.is_unit_notation("ABCdef1")

    assert false == Notation.is_unit_notation("")
    assert false == Notation.is_unit_notation(" ")
  end
end
