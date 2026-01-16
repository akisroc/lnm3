defmodule PlatformInfra.Database.Schemas.Whisper do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlatformInfra.Database.Schemas.Protagonist
  alias PlatformInfra.Database.Types.PrimaryKey

  @primary_key {:id, PrimaryKey, autogenerate: true}
  @foreign_key_type PrimaryKey

  schema "whispers" do
    field :content, :string
    field :is_read, :boolean, default: false

    belongs_to :sender, Protagonist
    belongs_to :receiver, Protagonist

    timestamps(type: :utc_datetime)
  end

  def create_changeset(whisper, attrs) do
    whisper
    |> cast(attrs, [:content, :protagonist_id])
    |> validate_required([:content, :protagonist_id])

    |> update_change(:content, &String.trim/1)
    |> validate_length(:content, min: 1, max: 500)

    |> validate_sender_is_not_receiver()

    |> assoc_constraint(:sender)
    |> assoc_constraint(:receiver)
  end

  def update_changeset(whisper, attrs) do
    whisper
    |> cast(attrs, [:is_read])
  end

  defp validate_sender_is_not_receiver(changeset) do
    sender_id = get_field(changeset, :sender_id)
    receiver_id = get_field(changeset, :receiver_id)

    if sender_id && receiver_id && sender_id == receiver_id do
      add_error(changeset, :receiver_id, "errors.whispers.self_sending")
    else
      changeset
    end
  end
end
