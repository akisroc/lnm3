defmodule Platform.Sovereignty.War.Types.BattleOutcome do
  alias Platform.Sovereignty.War
  alias Platform.Sovereignty.War.Types.{Troop, Unit, BattleLogEntry}
  alias Platform.Sovereignty.Ecto.Entities.Kingdom

  defstruct [
    :attacker_initial_troop,
    :defender_initial_troop,
    :attacker_final_troop,
    :defender_final_troop,
    attacker_wins?: false,
    log: [],
    attacker_initial_fame: 0.0,
    defender_initial_fame: 0.0,
    attacker_fame_modifier: 0.0,
    defender_fame_modifier: 0.0
  ]

  @type t :: %__MODULE__{
    attacker_initial_fame: float(),
    defender_initial_fame: float(),
    attacker_initial_troop: Troop.t(),
    defender_initial_troop: Troop.t(),
    log: [BattleLogEntry.t()],
    attacker_final_troop: Troop.t(),
    defender_final_troop: Troop.t(),
    attacker_wins?: boolean(),
    attacker_fame_modifier: float(),
    defender_fame_modifier: float()
  }
end
