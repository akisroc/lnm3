defmodule PlatformInfra.Database.Schemas.Kingdom do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlatformInfra.Database.Schemas.{User, Protagonist}
  alias PlatformInfra.Database.Types.Troop
  alias PlatformInfra.Database.Types.{PrimaryKey, Slug}

  @type t :: %__MODULE__{
    id: PrimaryKey.t() | nil,
    user_id: PrimaryKey.t() | nil,
    leader_id: PrimaryKey.t() | nil,
    name: String.t() | nil,
    slug: String.t() | nil,
    fame: Decimal.t() | nil,
    defense_troop: [non_neg_integer()] | nil,
    attack_troop: [non_neg_integer()] | nil,
    is_active: boolean() | nil,
    is_removed: boolean() | nil,
    inserted_at: DateTime.t() | nil,
    updated_at: DateTiime.t() | nil,
    user: Ecto.Association.NotLoaded.t() | User.t(),
    leader: Ecto.Association.NotLoaded.t() | Protagonist.t()
  }

  @type loaded :: %__MODULE__{
    id: PrimaryKey.t(),
    user_id: PrimaryKey.t(),
    leader_id: PrimaryKey.t(),
    name: String.t(),
    slug: String.t(),
    fame: Decimal.t(),
    defense_troop: [non_neg_integer()],
    attack_troop: [non_neg_integer()],
    is_active: boolean(),
    is_removed: boolean(),
    inserted_at: DateTime.t(),
    updated_at: DateTime.t(),
    user: Ecto.Association.NotLoaded.t() | User.t(),
    leader: Ecto.Association.NotLoaded.t() | Protagonist.t()
  }

  @name_regex ~r/^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-]+$/

  @primary_key {:id, PrimaryKey, autogenerate: true}
  @foreign_key_type PrimaryKey

  schema "kingdoms" do
    field :name, :string
    field :slug, Slug
    field :fame, :decimal, default: Decimal.new("30000.0")
    field :defense_troop, Troop, default: [0, 0, 0, 0, 0, 0, 0, 0]
    field :attack_troop, Troop, default: [0, 0, 0, 0, 0, 0, 0, 0]
    field :is_active, :boolean, default: false
    field :is_removed, :boolean, default: false

    belongs_to :user, User
    belongs_to :leader, Protagonist
    has_many :protagonists, Protagonist

    timestamps()
  end

  def create_changeset(kingdom, attrs) do
    kingdom
    |> cast(attrs, [:user_id, :leader_id, :name, :slug, :fame, :defense_troop, :attack_troop, :is_active, :is_removed])
    |> validate_required([:user_id, :leader_id, :name])
    |> unique_constraint(:name, name: :idx_kingdoms_name_not_removed)
    |> unique_constraint(:slug, name: "kingdoms_slug_key")
    |> validate_length(:slug, min: 1, max: 127)
    |> validate_fame()

    |> PrimaryKey.ensure_generation()
    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, min: 1, max: 63)
    |> validate_format(:name, @name_regex)
    |> Slug.generate(:name)
  end

  defp validate_fame(changeset) do
    validate_number(changeset, :fame, greater_than_or_equal_to: 0)
  end
end
