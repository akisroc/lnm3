# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Platform.Repo.insert!(%Platform.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query

alias PlatformInfra.Repo
alias PlatformInfra.Database.Schemas.{User, Session, Kingdom}
alias PlatformInfra.Database.Accounts

@nb_of_users = 50
@nb_of_kingdoms = 40

# INITIAL ADMIN
admin_params = %{
  nickname: System.get_env("ADMIN_USERNAME") || "Admin",
  email: System.get_env("ADMIN_EMAIL") || "admin@akisroc.org",
  password: System.get_env("ADMIN_PASSWORD") || "devdevdev"
}
Repo.transaction(fn ->
  case Repo.get_by(User, email: admin_params.email) do
    nil ->
      case Accounts.register_user(admin_params) do
        {:ok, _user} ->
          IO.puts("✅ Admin created")
        {:error, changeset} ->
          IO.puts("❌ Critical error on admin creation")
          IO.inspect(changeset.errors)
          Repo.rollback(:registration_failed)
      end

    _user -> IO.puts("Admin already exists. Seed ignored.")
  end
end)

env = Application.get_env(:platform, :env, :prod)

if env in [:test, :dev] do

  # --- USERS ---
  Repo.transaction(fn ->
    nicknames = Faker.Util.sample_uniq(@nb_of_users, &Faker.Internet.user_name/0)
    emails = Faker.Util.sample_uniq(@nb_of_users, &Faker.Internet.safe_email/0)

    for i <- 1..@nb_of_users do
      user = %User{}
      |> User.create_changeset(%{
        nickname: Enum.at(nicknames, i - 1),
        email: Enum.at(emails, i - 1),
        password: Faker.String.base64(16)
      })
      |> Repo.insert!()

      %Session{}
      |> Session.create_changeset(%{
        user_id: user.id,
        token: :crypto.hash(:sha256, :crypto.strong_rand_bytes(32)),
        ip_address: Faker.Internet.ip_v4_address(),
        user_agent: Faker.Internet.UserAgent.desktop_user_agent(),
        expires_at: Accounts.session_expires_at(user)
      })
      |> Repo.insert!()
    end

    IO.puts "✅ Created #{@nb_of_users} fake users"
  end)

  # --- KINGDOMS ---
  Repo.transaction(fn ->
    user_ids = Repo.all(from u in User, select: u.id)
    names = Faker.Util.sample_uniq(@nb_of_users, &Faker.Address.city/0)

    for i <- 1..@nb_of_kingdoms do
      %Kingdom{}
      |> Kingdom.create_changeset(%{
        name: Enum.at(names, i - 1),
        fame: (:rand.uniform() * 100_000.0) |> Float.round(3),
        defense_troop: Enum.map(1..8, fn _ -> Enum.random(0..2000) end),
        attack_troop:  Enum.map(1..8, fn _ -> Enum.random(0..2000) end),
        is_active: false,
        user_id: Enum.at(user_ids, i - 1)
      })
      |> Repo.insert!()
    end
    IO.puts "✅ Created #{@nb_of_kingdoms} fake kingdoms"
  end)
end
