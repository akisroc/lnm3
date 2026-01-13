defmodule PlatformWeb.BattleController do
  use PlatformWeb, :controller

  alias Platform.Sovereignty.Ecto.Entities.Kingdom
  alias Platform.Accounts.Ecto.Entities.User
  alias Platform.Sovereignty.Ecto.Repo, as: SovereigntyRepo
  alias Platform.Sovereignty.War

  def attack(conn, %{"atk_kingdom_id" => atk_kingdom_id, "def_kingdom_id" => def_kingdom_id}) do
    user = conn.assigns.current_account

    with {:ok, atk_kingdom} <- SovereigntyRepo.fetch_kingdom(atk_kingdom_id),
         {:ok, def_kingdom} <- SovereigntyRepo.fetch_kingdom(def_kingdom_id),
         :ok <- check_ownership(atk_kingdom, user),
         :ok <- check_active_status(atk_kingdom, def_kingdom),
         {:ok, battle_outcome} <- War.attack(
           atk_kingdom.attack_troop,
           def_kingdom.defense_troop,
           atk_kingdom.fame,
           def_kingdom.fame
         ),
         {:ok, battle} <- SovereigntyRepo.save_battle_result(battle_outcome, atk_kingdom, def_kingdom) do

      conn
      |> put_view(PlatformWeb.Views.BattleJSON)
      |> render(:show, battle)
    else
      {:error, :unauthorized} ->
        conn |> error(:forbidden, "User cannot attack with a foreign kingdom")
      {:error, :inactive_kingdom} ->
        conn |> error(:forbidden, "One of the kingdoms is not active")
      {:error, :not_found} ->
        conn |> error(:not_found, "Target kingdom does not exist")
      {:error, reason} ->
        conn |> error(:bad_request, reason)
    end
  end

  @spec check_ownership(Kingdom.t(), User.t()) :: :ok | {:error, :unauthorized}
  defp check_ownership(kingdom, user) do
    if kingdom.user_id == user.id do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  @spec check_active_status(Kingdom.t(), Kingdom.t()) :: :ok | {:error, :inactive_kingdom}
  defp check_active_status(atk_kingdom, def_kingdom) do
    if atk_kingdom.is_active? and def_kingdom.is_active? do
      :ok
    else
      {:error, :inactive_kingdom}
    end
  end

  defp error(conn, status, message) do
    conn
    |> put_status(status)
    |> json(%{message: message})
  end
end
