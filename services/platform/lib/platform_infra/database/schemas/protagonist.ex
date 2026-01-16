defmodule PlatformInfra.Database.Schemas.Protagonist do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlatformInfra.Database.Schemas.{User, Kingdom}
  alias PlatformInfra.Database.Types.{PrimaryKey, Slug, Url}

  @name_regex ~r/^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ''’\-]+$/

  @primary_key {:id, PrimaryKey, autogenerate: true}
  @foreign_key_type PrimaryKey

  @type t :: %__MODULE__{
    id: PrimaryKey.t() | nil,
    user_id: PrimaryKey.t() | nil,
    kingdom_id: PrimaryKey.t() | nil,
    name: String.t() | nil,
    fame: Decimal.t() | nil,
    slug: String.t() | nil,
    is_anonymous: boolean() | nil,
    biography: String.t() | nil,
    is_removed: boolean() | nil,
    inserted_at: DateTime.t() | nil,
    updated_at: DateTiime.t() | nil,
    user: Ecto.Association.NotLoaded.t() | User.t(),
    kingdom: Ecto.Association.NotLoaded.t() | Kingdom.t()
  }

  @type loaded :: %__MODULE__{
    id: PrimaryKey.t(),
    user_id: PrimaryKey.t(),
    kingdom_id: PrimaryKey.t() | nil,
    name: String.t(),
    fame: Decimal.t(),
    slug: String.t(),
    is_anonymous: boolean(),
    biography: String.t() | nil,
    is_removed: boolean(),
    inserted_at: DateTime.t(),
    updated_at: DateTiime.t(),
    user: Ecto.Association.NotLoaded.t() | User.t(),
    kingdom: Ecto.Association.NotLoaded.t() | Kingdom.t()
  }

  schema "protagonists" do
    field :name, :string
    field :fame, :decimal, default: Decimal.new("0.0")
    field :slug, Slug
    field :is_anonymous, :boolean, default: true
    field :profile_picture, Url
    field :biography, :string
    field :is_removed, :boolean, default: false

    belongs_to :user, User
    belongs_to :kingdom, Kingdom

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(protagonist, attrs) do
    protagonist
    |> cast(attrs, [:name, :slug, :is_anonymous, :profile_picture, :biography, :user_id, :kingdom_id])
    |> validate_required([:name, :user_id])

    |> PrimaryKey.ensure_generation()
    |> Slug.generate(:name)

    |> unique_constraint(:name, name: :idx_protagonists_name_not_removed)
    |> unique_constraint([:id, :user_id], name: :idx_protagonists_id_user_id)

    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, min: 1, max: 30)
    |> validate_format(:name, @name_regex)

    |> validate_length(:biography, min: 1, max: 500000)
  end

  def update_changeset(protagonist, attrs) do
    protagonist
    |> cast(attrs, [:name, :fame, :slug, :is_anonymous, :profile_picture, :biography, :is_removed, :kingdom_id])

    |> unique_constraint(:name, name: :idx_protagonists_name_not_removed)

    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, min: 1, max: 30)
    |> validate_format(:name, @name_regex)

    |> validate_length(:biography, min: 1, max: 500000)
  end
end
