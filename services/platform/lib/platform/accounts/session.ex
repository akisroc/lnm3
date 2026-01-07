defmodule Platform.Accounts.Session do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @session_validity_in_days 120
  @session_validity_in_seconds 60 * 60 * 24 * @session_validity_in_days

  @primary_key {:id, Platform.EctoTypes.UUIDv7, autogenerate: true}
  @foreign_key_type Platform.EctoTypes.UUIDv7

  schema "sessions" do
    field :token, :binary
    field :context, :string, default: "session"
    field :ip_address, EctoNetwork.INET
    field :user_agent, :string
    field :expires_at, :utc_datetime

    belongs_to :user, Platform.Accounts.User

    timestamps(updated_at: false, type: :utc_datetime)
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:token, :context, :ip_address, :user_id, :user_agent, :expires_at])
    |> validate_required([:token, :context, :ip_address, :user_id, :expires_at])
    |> unique_constraint(:token)
  end

  def generate_session_token(user, ip_address, user_agent) do
    token_bytes = :crypto.strong_rand_bytes(32)
    token_hashed = :crypto.hash(:sha256, token_bytes)

    {:ok, inet_addr} = :inet.parse_address(to_charlist(ip_address))

    Platform.Repo.insert!(%Platform.Accounts.Session{
      user_id: user.id,
      token: token_hashed,
      context: "session",
      ip_address: %Postgrex.INET{address: inet_addr},
      user_agent: user_agent,
      expires_at: expires_at(user)
    })

    token_bytes
  end

  def get_user_by_session_token(token) do
    with {:ok, token_bin} <- Base.url_decode64(token, padding: false) do
      token_hashed = :crypto.hash(:sha256, token_bin)

      query = from s in Platform.Accounts.Session,
        where: s.token == ^token_hashed,
        where: s.expires_at > fragment("now()"),
        preload: [:user]

      case Platform.Repo.one(query) do
        nil -> {:error, :not_found}
        session -> {:ok, session.user}
      end
    else
      _ -> {:error, :invalid_encoding}
    end

  end

  def delete_session_token(token) do
    Platform.Repo.delete_all(
      from s in Platform.Accounts.Session, where: s.token == ^token
    )

    :ok
  end

  def delete_expired_sessions do
    Platform.Repo.delete_all(
      from(s in Platform.Accounts.Session, where: s.expires_at < fragment("now()"))
    )

    :ok
  end

  # Todo: Shorter session for admins and GMs
  def expires_at(_user) do
    DateTime.utc_now()
      |> DateTime.add(@session_validity_in_seconds, :second)
      |> DateTime.truncate(:second)
  end

  def session_validity_in_days, do: @session_validity_in_days
  def session_validity_in_seconds, do: @session_validity_in_seconds
end
