defmodule NotationTest do
  use ExUnit.Case
  doctest Notation

  test "validates unit notations" do
    assert Notation.unit_notation?("0000000")
    assert Notation.unit_notation?("0000950")
    assert Notation.unit_notation?("0022345")
    assert Notation.unit_notation?("1234590")
    assert Notation.unit_notation?("2000000")


    assert not Notation.unit_notation?("00002345")
    assert not Notation.unit_notation?("0023445567")
    assert not Notation.unit_notation?("234")
    assert not Notation.unit_notation?("000")
    assert not Notation.unit_notation?("0")

    assert not Notation.unit_notation?("000000A")
    assert not Notation.unit_notation?("ABCdef1")

    assert not Notation.unit_notation?("")
    assert not Notation.unit_notation?(" ")
  end

  test "validates troup notations" do
    assert Notation.troup_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
    assert Notation.troup_notation?("0000000/0000000/0000000/0000000/0000000/0000000/0000000/0000000")
    assert Notation.troup_notation?("9999999/9999999/9999999/9999999/9999999/9999999/9999999/9999999")

    # No zero padding
    assert not Notation.troup_notation?("995/20/600/400/30/0/60/20")
    # Too many units
    assert not Notation.troup_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020/0000450")
    # Not enough units
    assert not Notation.troup_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060")
    # Trailing separator
    assert not Notation.troup_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020/")
    # Leading separator
    assert not Notation.troup_notation?("/0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
    # Wrong separator
    assert not Notation.troup_notation?("0000995 0000020 0000600 0000400 0000030 0000000 0000060 0000020")
    # No separator
    assert not Notation.troup_notation?("00009950000020000060000004000000030000000000000600000020")
    # Letters
    assert not Notation.troup_notation?("0000995/ABCDEFG/0000600/0000400/0000030/0000000/0000060/0000020")
  end

  test "validates battle state notations" do
    assert Notation.battle_state_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")

    # Too many troups
    assert not Notation.battle_state_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
    # Not enough troups
    assert not Notation.battle_state_notation?("9999999/9999999/9999999/9999999/9999999/9999999/9999999/9999999")
  end

  test "parses notations" do
    assert Notation.parse("0000995")
      === 995
    assert Notation.parse("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
      === [995, 20, 600, 400, 30, 0, 60, 20]
    assert Notation.parse("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
      === [[995, 20, 600, 400, 30, 0, 60, 20], [995, 20, 600, 400, 30, 0, 60, 20]]
    assert Notation.parse("0000000/0000000/0000000/0000000/0000000/0000000/0000000/0000000 0000000/0000000/0000000/0000000/0000000/0000000/0000000/0000000")
      === [[0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0]]
    assert Notation.parse("9999999/9999999/9999999/9999999/9999999/9999999/9999999/9999999 9999999/9999999/9999999/9999999/9999999/9999999/9999999/9999999")
      === [[9999999, 9999999, 9999999, 9999999, 9999999, 9999999, 9999999, 9999999], [9999999, 9999999, 9999999, 9999999, 9999999, 9999999, 9999999, 9999999]]
  end

  test "serialises notation" do
    assert Notation.serialise(45) === "0000045"
    assert Notation.serialise(0) === "0000000"
    assert Notation.serialise(9999999) === "9999999"
    assert Notation.serialise(1000000) === "1000000"
    assert Notation.serialise(400000) === "0400000"

    assert Notation.serialise([995, 20, 600, 400, 30, 0, 60, 20])
      === "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020"
    assert Notation.serialise([[995, 20, 600, 400, 30, 0, 60, 20], [995, 20, 600, 400, 30, 0, 60, 20]])
      === "0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020"
    assert Notation.serialise([[0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0]])
      === "0000000/0000000/0000000/0000000/0000000/0000000/0000000/0000000 0000000/0000000/0000000/0000000/0000000/0000000/0000000/0000000"
    assert Notation.serialise([[9999999, 9999999, 9999999, 9999999, 9999999, 9999999, 9999999, 9999999], [9999999, 9999999, 9999999, 9999999, 9999999, 9999999, 9999999, 9999999]])
      === "9999999/9999999/9999999/9999999/9999999/9999999/9999999/9999999 9999999/9999999/9999999/9999999/9999999/9999999/9999999/9999999"

    assert_raise ArgumentError, fn -> Notation.serialise(-20) end
    assert_raise ArgumentError, fn -> Notation.serialise(19999999) end
    assert_raise ArgumentError, fn -> Notation.serialise([22, 30]) end
    assert_raise ArgumentError, fn -> Notation.serialise([1, 2, 3, 4, 5, 6, 7, 8, 9]) end
    assert_raise ArgumentError, fn -> Notation.serialise([]) end
    assert_raise ArgumentError, fn -> Notation.serialise([[1, 2], [2, 3, 5]]) end
    assert_raise ArgumentError, fn -> Notation.serialise([[], []]) end
    assert_raise ArgumentError, fn -> Notation.serialise([[0], []]) end
    assert_raise ArgumentError, fn -> Notation.serialise([[1, 2, 3, 4, 5, 6, 7, 8], [1, 2, 3, 4, 5, 6, 7, 8], [1, 2, 3, 4, 5, 6, 7, 8]]) end
  end
end
