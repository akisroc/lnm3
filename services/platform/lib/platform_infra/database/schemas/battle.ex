defmodule PlatformInfra.Database.Schemas.Battle do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlatformInfra.Database.Types.Troop
  alias PlatformInfra.Database.Schemas.Kingdom
  alias PlatformInfra.Database.Types.PrimaryKey

  @type t :: %__MODULE__{
    id: PrimaryKey.t() | nil,
    attacker_kingdom_id: PrimaryKey.t() | nil,
    defender_kingdom_id: PrimaryKey.t() | nil,
    attacker_initial_troop: [non_neg_integer()] | nil,
    defender_initial_troop: [non_neg_integer()] | nil,
    log: map() | nil,
    attacker_final_troop: [non_neg_integer()] | nil,
    defender_final_troop: [non_neg_integer()] | nil,
    attacker_wins?: boolean() | nil,
    attacker_fame_modifier: Decimal.t() | nil,
    defender_fame_modifier: Decimal.t() | nil,
    inserted_at: DateTime.t() | nil,
    attacker_kingdom: Ecto.Association.NotLoaded.t() | Kingdom.t(),
    defender_kingdom: Ecto.Association.NotLoaded.t() | Kingdom.t()
  }

  @type loaded :: %__MODULE__{
    id: PrimaryKey.t(),
    attacker_kingdom_id: PrimaryKey.t(),
    defender_kingdom_id: PrimaryKey.t(),
    attacker_initial_troop: [non_neg_integer()],
    defender_initial_troop: [non_neg_integer()],
    log: map(),
    attacker_final_troop: [non_neg_integer()],
    defender_final_troop: [non_neg_integer()],
    attacker_wins?: boolean(),
    attacker_fame_modifier: Decimal.t(),
    defender_fame_modifier: Decimal.t(),
    inserted_at: DateTime.t(),
    attacker_kingdom: Ecto.Association.NotLoaded.t() | Kingdom.t(),
    defender_kingdom: Ecto.Association.NotLoaded.t() | Kingdom.t()
  }

  @primary_key {:id, PrimaryKey, autogenerate: true}
  @foreign_key_type PrimaryKey

  schema "battles" do
    field :attacker_initial_troop, Troop
    field :defender_initial_troop, Troop
    field :log, :map
    field :attacker_final_troop, Troop
    field :defender_final_troop, Troop
    field :attacker_wins?, :boolean, source: :attacker_wins
    field :attacker_fame_modifier, :decimal
    field :defender_fame_modifier, :decimal

    timestamps(updated_at: false, type: :utc_datetime)

    belongs_to :attacker_kingdom, Kingdom, foreign_key: :attacker_kingdom_id
    belongs_to :defender_kingdom, Kingdom, foreign_key: :defender_kingdom_id
  end

  @doc """
  Battles are immutable.
  Once inserted, they are history, they will never change.
  """
  def create_changeset(battle, attrs) do
    battle
    |> cast(attrs, [
      :attacker_kingdom_id,
      :defender_kingdom_id,
      :attacker_initial_troop,
      :defender_initial_troop,
      :log,
      :attacker_final_troop,
      :defender_final_troop,
      :attacker_wins?,
      :attacker_fame_modifier,
      :defender_fame_modifier
    ])
    |> validate_required([
      :attacker_kingdom_id,
      :defender_kingdom_id,
      :attacker_initial_troop,
      :defender_initial_troop,
      :log,
      :attacker_final_troop,
      :defender_final_troop,
      :attacker_wins?,
      :attacker_fame_modifier,
      :defender_fame_modifier
    ])
    |> foreign_key_constraint(:attacker_kingdom_id)
    |> foreign_key_constraint(:defender_kingdom_id)
    |> check_constraint(:attacker_kingdom_id, name: :chk_battles_attacker_is_not_defender)
  end
end
