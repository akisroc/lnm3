defmodule PlatformInfra.Database.Schemas.Missive do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlatformInfra.Database.Schemas.Kingdom
  alias PlatformInfra.Database.Types.PrimaryKey

  @primary_key {:id, PrimaryKey, autogenerate: true}
  @foreign_key_type PrimaryKey

  schema "missives" do
    field :content, :string
    field :is_read, :boolean, default: false
      
    belongs_to :sender, Kingdom
    belongs_to :receiver, Kingdom

    timestamps(type: :utc_datetime)
  end

  def create_changeset(missive, attrs) do
    missive
    |> cast(attrs, [:content, :sender_id, :receiver_id])
    |> validate_required([:content, :sender_id, :receiver_id])

    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, min: 1, max: 10000)

    |> validate_sender_is_not_receiver()

    |> assoc_constraint(:sender)
    |> assoc_constraint(:receiver)
  end

  def update_changeset(missive, attrs) do
    missive
    |> cast(attrs, [:is_read])
  end

  defp validate_sender_is_not_receiver(changeset) do
    sender_id = get_field(changeset, :sender_id)
    receiver_id = get_field(changeset, :receiver_id)

    if sender_id && receiver_id && sender_id == receiver_id do
      add_error(changeset, :receiver_id, "errors.missives.self_sending")
    else
      changeset
    end
  end
end
