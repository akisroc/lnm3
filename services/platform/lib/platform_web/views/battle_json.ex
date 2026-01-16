defmodule PlatformWeb.Views.BattleJSON do
  alias PlatformInfra.Database.Schemas.Battle

  @public_fields [
    :id,
    :attacker_kingdom_id,
    :defender_kingdom_id,
    :attacker_initial_troop,
    :defender_initial_troop,
    :log,
    :attacker_final_troop,
    :defender_final_troop,
    :attacker_wins?,
    :attacker_fame_modifier,
    :defender_fame_modifier,
    :inserted_at
  ]

  @spec show(Battle.loaded()) :: map()
  def show(battle) do
    battle
    |> Map.take(@public_fields)
  end
end
