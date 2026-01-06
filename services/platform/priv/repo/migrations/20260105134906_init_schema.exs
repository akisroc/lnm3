defmodule Platform.Repo.Migrations.InitSchema do
  use Ecto.Migration

  def up do
    execute_sql_file Application.app_dir(:platform, "priv/repo/migrations/init_db.sql")

  end

  def down do
    execute_sql_file Application.app_dir(:platform, "priv/repo/migrations/deinit_db.sql")
  end

  # Ecto cannot execute multiple `xxx;` SQL commands at once.
  # Have to split SQL into multiple subcommands when calling an
  # external file.
  #
  # The split is simple, so keep the SQL file simple to:
  # no `\s*\n` after a `;`.
  defp execute_sql_file(path) do
    path
    |> File.read!()
    |> String.split(~r/;\s*\n/)
    |> Stream.map(&String.trim/1)
    |> Stream.reject(&(&1 === ""))
    |> Enum.each(&execute/1)
  end
end
