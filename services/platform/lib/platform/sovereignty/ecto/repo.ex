defmodule Platform.Sovereignty.Ecto.Repo do
  alias Ecto.{Changeset, Multi}

  alias Platform.Repo
  alias Platform.Ecto.Types.PrimaryKey
  alias Platform.Sovereignty.Ecto.Entities.Kingdom

  alias Platform.Sovereignty.Ecto.Entities.Battle
  alias Platform.Sovereignty.War.Types.{BattleOutcome, BattleLogEntry}

  @spec get_kingdom(PrimaryKey.t()) :: {:ok, Kingdom.t()} | {:error, :not_found}
  def get_kingdom(id) do
    case Repo.get(Kingdom, id) do
      nil -> {:error, :not_found}
      kingdom -> {:ok, kingdom}
    end
  end

  @doc """
  Persist the result of a battle.
  Update both kingdoms’ troops and fame, and insert the the battle.
  """
  @spec save_battle_result(BattleOutcome.t(), Kingdom.t(), Kingdom.t()) :: {:ok, Battle.loaded()}
  def save_battle_result(%BattleOutcome{} = battle_outcome, %Kingdom{} = atk_kingdom, %Kingdom{} = def_kingdom) do
    atk_initial_troop = Troop.to_raw(battle_outcome.attacker_initial_troop)
    def_initial_troop = Troop.to_raw(battle_outcome.defender_initial_troop)
    atk_final_troop = Troop.to_raw(battle_outcome.attacker_final_troop)
    def_final_troop = Troop.to_raw(battle_outcome.defender_final_troop)
    log = Enum.map(battle_outcome.log, &BattleLogEntry.to_raw/1)

    Multi.new()
    |> Multi.update(:update_attacker, Changeset.change(atk_kingdom, %{
      attack_troop: atk_final_troop,
      fame: atk_kingdom + battle_outcome.attacker_fame_modifier
    }))
    |> Multi.update(:update_defender, Changeset.change(def_kingdom, %{
      attack_troop: def_final_troop,
      fame: def_kingdom + battle_outcome.defender_fame_modifier
    }))
    |> Multi.insert(:insert_battle, %Battle{
      attacker_kingdom_id: atk_kingdom.id,
      defender_kingdom_id: def_kingdom.id,
      attacker_initial_troop: atk_initial_troop,
      defender_initial_troop: def_initial_troop,
      log: log,
      defender_final_troop: def_final_troop,
      attacker_final_troop: atk_final_troop,
      attacker_wins?: battle_outcome.attacker_wins?,
      attacker_fame_modifier: battle_outcome.attacker_fame_modifier,
      defender_fame_modifier: battle_outcome.defender.fame_modifier
    })
    |> Repo.transaction()
    |> handle_transaction_result()
  end

  @spec handle_transaction_reasult({:ok | Battle.loaded()} | {:error, any(), any(), any()}) :: {:ok, Battle.loaded()} | {:error, any()}
  defp handle_transaction_result({:ok, %{insert_battle: battle}}) do
    {:ok, battle}
  end
  defp handle_transaction_result({:error, _step, reason, _changes}) do
    {:error, reason}
  end
end
