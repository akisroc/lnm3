defmodule PlatformWeb.BattleController do
  use PlatformWeb, :controller

  alias PlatformInfra.Database.Schemas.Kingdom
  alias PlatformInfra.Database.Schemas.User
  alias PlatformInfra.Database.Sovereignty, as: SovereigntyRepo
  alias Platform.Sovereignty.War

  def attack(
    %{assigns: %{current_account: user}} = conn,
    %{"atk_kingdom_id" => atk_kingdom_id, "def_kingdom_id" => def_kingdom_id}
  ) do
    with {:ok, atk_kingdom} <- SovereigntyRepo.get_kingdom(atk_kingdom_id),
         {:ok, def_kingdom} <- SovereigntyRepo.get_kingdom(def_kingdom_id),
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
  defp check_ownership(%{user_id: u_id}, %{id: u_id}), do: :ok
  defp check_ownership(_, _), do: {:error, :unauthorized}

  @spec check_active_status(Kingdom.t(), Kingdom.t()) :: :ok | {:error, :inactive_kingdom}
  defp check_active_status(%{is_active: true}, %{is_active: true}), do: :ok
  defp check_active_status(_, _), do: {:error, :inactive_kingdom}

  defp error(conn, status, message) do
    conn
    |> put_status(status)
    |> json(%{message: message})
  end
end
