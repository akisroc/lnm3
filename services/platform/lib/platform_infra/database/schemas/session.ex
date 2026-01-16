defmodule PlatformInfra.Database.Schemas.Session do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlatformInfra.Database.Schemas.User
  alias PlatformInfra.Database.Types.PrimaryKey

  @primary_key {:id, PrimaryKey, autogenerate: true}
  @foreign_key_type PrimaryKey

  schema "sessions" do
    field :token, :binary
    field :context, :string, default: "session"
    field :ip_address, EctoNetwork.INET
    field :user_agent, :string
    field :expires_at, :utc_datetime

    belongs_to :user, User

    timestamps(updated_at: false, type: :utc_datetime)
  end

  @doc false
  def create_changeset(session, attrs) do
    session
    |> cast(attrs, [:token, :context, :ip_address, :user_id, :user_agent, :expires_at])
    |> validate_required([:token, :context, :ip_address, :user_id, :expires_at])
    |> unique_constraint(:token, name: "sessions_token_key")
  end
end
