defmodule BattleTest do
  use ExUnit.Case
  doctest Battle

  # Todo: best tests for battles
  test "solve battles" do
    Battle.solve_battle("0000995/0000400/0000600/0000800/0001200/0000660/0000450/0000020 0001500/0000135/0001000/0000100/0000200/0000000/0000600/0000100")
    |> IO.inspect()
  end
end
