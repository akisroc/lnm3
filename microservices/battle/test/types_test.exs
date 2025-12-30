defmodule TypesTest do
  use ExUnit.Case
  doctest Battle.Unit
  doctest Battle.Troup
  doctest Battle.BattleState

  test "validates unit notations" do
    assert Battle.Unit.valid_notation?("0000000")
    assert Battle.Unit.valid_notation?("0000950")
    assert Battle.Unit.valid_notation?("0022345")
    assert Battle.Unit.valid_notation?("1234590")
    assert Battle.Unit.valid_notation?("2000000")


    assert not Battle.Unit.valid_notation?("00002345")
    assert not Battle.Unit.valid_notation?("0023445567")
    assert not Battle.Unit.valid_notation?("234")
    assert not Battle.Unit.valid_notation?("000")
    assert not Battle.Unit.valid_notation?("0")

    assert not Battle.Unit.valid_notation?("000000A")
    assert not Battle.Unit.valid_notation?("ABCdef1")

    assert not Battle.Unit.valid_notation?("")
    assert not Battle.Unit.valid_notation?(" ")
  end

  test "validates troup notations" do
    assert Battle.Troup.valid_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
    assert Battle.Troup.valid_notation?("0000000/0000000/0000000/0000000/0000000/0000000/0000000/0000000")
    assert Battle.Troup.valid_notation?("9999999/9999999/9999999/9999999/9999999/9999999/9999999/9999999")

    # No zero padding
    assert not Battle.Troup.valid_notation?("995/20/600/400/30/0/60/20")
    # Too many units
    assert not Battle.Troup.valid_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020/0000450")
    # Not enough units
    assert not Battle.Troup.valid_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060")
    # Trailing separator
    assert not Battle.Troup.valid_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020/")
    # Leading separator
    assert not Battle.Troup.valid_notation?("/0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
    # Wrong separator
    assert not Battle.Troup.valid_notation?("0000995 0000020 0000600 0000400 0000030 0000000 0000060 0000020")
    # No separator
    assert not Battle.Troup.valid_notation?("00009950000020000060000004000000030000000000000600000020")
    # Letters
    assert not Battle.Troup.valid_notation?("0000995/ABCDEFG/0000600/0000400/0000030/0000000/0000060/0000020")
  end

  test "validates battle state notations" do
    assert Battle.BattleState.valid_notation?("0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020 0000995/0000020/0000600/0000400/0000030/0000000/0000060/0000020")
  end
end
