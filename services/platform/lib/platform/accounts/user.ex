defmodule Platform.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Platform.Utils.SlugUtils

  @username_regex ~r/^[ a-zA-Z0-9éÉèÈêÊëËäÄâÂàÀïÏöÖôÔüÜûÛçÇ\'’\-_\.&]+$/
  @email_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
  @url_regex ~r/^https?:\/\/[\w\d\-._~:?#\[\]@!$&'()*+,;=%\/]+$/
  @slug_regex ~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/

  @primary_key {:id, Platform.EctoTypes.UUIDv7, autogenerate: true}
  @foreign_key_type Platform.EctoTypes.UUIDv7

  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string, redact: true  # Hides password in logs

    field :profile_picture, :string
    field :slug, :string
    field :platform_theme, Ecto.Enum, values: [:dark, :light]
    field :is_enabled, :boolean, default: true
    field :is_removed, :boolean, default: false

    has_many :sessions, Platform.Accounts.Session

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :profile_picture, :password, :slug, :platform_theme, :is_enabled])
    |> validate_required([:username, :email, :password])
    |> unique_constraint([:username, :email, :slug])

    |> update_change(:username, &String.trim/1)
    |> validate_length(:username, min: 1, max: 30)
    |> validate_format(:username, @username_regex)
    |> generate_unique_slug(:username)
    |> validate_format(:slug, @slug_regex)

    |> update_change(:email, &String.trim/1)
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:email, min: 1, max: 500)
    |> validate_format(:email, @email_regex)

    |> validate_inclusion(:platform_theme, [:dark, :light])

    |> validate_length(:profile_picture, min: 1, max: 500)
    |> validate_format(:profile_picture, @url_regex)

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

  # Todo: Could (should?) be in global configs
  defp argon2_config() do
    if Mix.env() in [:test, :dev] do
      [
        t_cost: 1,
        m_cost: 8,
        parallelism: System.schedulers_online(),
        argon2_type: 2
      ]
    else
      [
        t_cost: 4,
        m_cost: 18,  # 2^18 KiB => 256MiB
        parallelism: System.schedulers_online(),
        argon2_type: 2  # Argon2id
      ]
    end
  end
end
