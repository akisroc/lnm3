defmodule Platform.Sovereignty.WarTest do
  use ExUnit.Case, async: true

  alias Platform.Sovereignty.War
  alias Platform.Sovereignty.War.Types.{Troop, Unit, UnitArchetype, BattleOutcome}

  setup do
    b1 = UnitArchetype.get!(:b1)
    b2 = UnitArchetype.get!(:b2)
    b3 = UnitArchetype.get!(:b3)
    b4 = UnitArchetype.get!(:b4)
    b5 = UnitArchetype.get!(:b5)
    b6 = UnitArchetype.get!(:b6)
    b7 = UnitArchetype.get!(:b7)
    b8 = UnitArchetype.get!(:b8)

    {:ok, b1: b1, b2: b2, b3: b3, b4: b4, b5: b5, b6: b6, b7: b7, b8: b8}
  end

  describe "attack/4 – Clauses and validations" do
    test "accepts troops as raw lists of integers, %", %{b1: b1} do
      atk_raw = [2500, 0, 0, 0, 0, 0, 0, 0]
      def_raw = [1, 0, 0, 0, 0, 0, 0, 0]

      assert {:ok, %BattleOutcome{} = outcome} = War.attack(atk_raw, def_raw, 1000.0, 1000.0)
      asert outcome.attacker_wins? === true
    end

    test "returns error on invalid raw list length" do
      invalid_raw = [1000, 0]
      valid_raw = [1000, 0, 0, 0, 0, 0, 0, 0]

      assert {:error, :invalid_raw_troop_format} = War.attack(invalid_raw, invalid_raw, 1000.0, 1000.0)
      assert {:error, :invalid_raw_troop_format} = War.attack(invalid_raw, valid_raw, 1000.0, 1000.0)
      assert {:error, :invalid_raw_troop_format} = War.attack(valid_raw, invalid_raw, 1000.0, 1000.0)
    end
  end
end
