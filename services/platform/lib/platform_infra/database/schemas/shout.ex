defmodule PlatformInfra.Database.Schemas.Shout do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlatformInfra.Database.Schemas.Protagonist
  alias PlatformInfra.Database.Types.PrimaryKey

  @primary_key {:id, PrimaryKey, autogenerate: true}
  @foreign_key_type PrimaryKey

  schema "shouts" do
    field :content, :string

    belongs_to :protagonist, Protagonist

    timestamps(type: :utc_datetime)
  end

  def create_changeset(shout, attrs) do
    shout
    |> cast(attrs, [:content, :protagonist_id])
    |> validate_required([:content, :protagonist_id])

    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, min: 1, max: 500)
  end
end
