defmodule PlatformInfra.Database.Entities.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlatformInfra.Database.Entities.Session
  alias PlatformInfra.Database.Types.{PrimaryKey, Slug, Url}

  @nickname_regex ~r/^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ\'’\-_\.&]+$/
  @email_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/

  @primary_key {:id, PrimaryKey, autogenerate: true}
  @foreign_key_type PrimaryKey

  schema "users" do
    field :nickname, :string
    field :email, :string
    field :password, :string, redact: true  # Hides password in logs

    field :profile_picture, Url
    field :slug, Slug
    field :platform_theme, Ecto.Enum, values: [:dark, :light]
    field :is_enabled, :boolean, default: true
    field :is_removed, :boolean, default: false

    has_many :sessions, Session

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [:nickname, :email, :profile_picture, :password, :slug, :platform_theme, :is_enabled])
    |> validate_required([:nickname, :email, :password])
    |> unique_constraint(:nickname, name: :idx_users_nickname_not_removed)
    |> unique_constraint(:email, name: :idx_users_email_not_removed)
    |> unique_constraint(:slug, name: :users_slug_key)

    |> update_change(:nickname, &String.trim/1)
    |> validate_length(:nickname, min: 1, max: 30)
    |> validate_format(:nickname, @nickname_regex)

    |> update_change(:email, &String.trim/1)
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:email, min: 1, max: 500)
    |> validate_format(:email, @email_regex)

    |> validate_inclusion(:platform_theme, [:dark, :light])

    |> PrimaryKey.ensure_generation()
    |> Slug.generate(:nickname)

    |> validate_length(:password, min: 8, max: 72)
    |> hash_password()
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password, Argon2.hash_pwd_salt(password, argon2_config()))
    else
      changeset
    end
  end

  # Todo: Could (should) be in global configs
  defp argon2_config() do
    env = Application.get_env(:platform, :env, :prod)

    case env do
      :test -> [
        t_cost: 1,
        m_cost: 6,
        parallelism: 1,
        argon2_type: 2
      ]
      :dev -> [
        t_cost: 2,
        m_cost: 12,
        parallelism: System.schedulers_online(),
        argon2_type: 2
      ]
      :prod -> [
        t_cost: 4,
        m_cost: 18,  # 2^18 KiB => 256MiB
        parallelism: 2,
        argon2_type: 2  # Argon2id
      ]
    end
  end
end
