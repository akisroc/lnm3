defmodule PlatformInfra.Database.Accounts do
  import Ecto.Query

  alias Ecto.Multi

  alias PlatformInfra.Database.Schemas.{User, Session, Kingdom, Protagonist}
  alias PlatformInfra.Repo

  @session_validity_in_days 120
  @session_validity_in_seconds 60 * 60 * 24 * @session_validity_in_days

  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    cond do
      user && Argon2.verify_pass(password, user.password) && user.is_enabled && !user.is_removed ->
        {:ok, user}

      user && user.is_removed -> {:error, :removed}

      user && !user.is_enabled -> {:error, :disabled}

      true ->
        Argon2.no_user_verify()
        {:error, :unauthorized}
    end
  end

  def register_user(%{
      user_nickname: user_nickname,
      user_email: user_email,
      user_password: user_password,
      kingdom_name: kingdom_name,
      leader_name: leader_name
  }) do
    Multi.new()

    |> Multi.insert(:user, User.create_changeset(%User{}, %{
      nickname: user_nickname, email: user_email, password: user_password
    }))

    |> Multi.insert(:protagonist, fn %{user: user} ->
      Protagonist.create_changeset(%Protagonist{}, %{name: leader_name, user_id: user.id})
    end)

    |> Multi.insert(:kingdom, fn %{user: user, protagonist: leader} ->
      Kingdom.create_changeset(%Kingdom{}, %{name: kingdom_name, user_id: user.id, leader_id: leader.id})
    end)

    |> Multi.update(:link_leader_to_kingdom, fn %{protagonist: leader, kingdom: kingdom} ->
      Protagonist.update_changeset(leader, %{kingdom_id: kingdom.id})
    end)

    |> Repo.transaction()
  end

  def generate_session_token(user, ip_address, user_agent) do
    token_bytes = :crypto.strong_rand_bytes(32)
    token_hashed = :crypto.hash(:sha256, token_bytes)

    {:ok, inet_addr} = :inet.parse_address(to_charlist(ip_address))

    Repo.insert!(%Session{
      user_id: user.id,
      token: token_hashed,
      context: "session",
      ip_address: %Postgrex.INET{address: inet_addr},
      user_agent: user_agent,
      expires_at: session_expires_at(user)
    })

    token_bytes
  end

  def get_user_by_session_token(token) do
    with {:ok, token_bin} <- Base.url_decode64(token, padding: false) do
      token_hashed = :crypto.hash(:sha256, token_bin)

      query = from s in Session,
        where: s.token == ^token_hashed,
        where: s.expires_at > fragment("now()"),
        preload: [:user]

      case Repo.one(query) do
        nil -> {:error, :not_found}
        session -> {:ok, session.user}
      end
    else
      _ -> {:error, :invalid_encoding}
    end

  end

  def delete_session_token(token) do
    Repo.delete_all(
      from s in Session, where: s.token == ^token
    )

    :ok
  end

  @spec delete_expired_sessions :: {:ok, non_neg_integer()}
  def delete_expired_sessions do
    {count, _} = Repo.delete_all(
      from s in Session, where: s.expires_at < fragment("now()")
    )

    {:ok, count}
  end

  def session_expires_at(_user) do
    DateTime.utc_now()
      |> DateTime.add(@session_validity_in_seconds, :second)
      |> DateTime.truncate(:second)
  end

  def session_validity_in_days, do: @session_validity_in_days
  def session_validity_in_seconds, do: @session_validity_in_seconds
end
