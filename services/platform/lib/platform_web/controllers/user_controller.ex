defmodule PlatformWeb.UserController do
  use PlatformWeb, :controller

  alias Ecto.Changeset
  alias PlatformInfra.Database.Accounts

  def me(conn, _params) do
    # Extract token from cookie
    token = conn.cookies["_platform_user_token"]

    if token do
      case Accounts.get_user_by_session_token(token) do
        {:ok, user} ->
          conn
          |> put_status(:ok)
          |> json(%{
            id: user.id,
            nickname: user.nickname,
            email: user.email,
            profile_picture: user.profile_picture,
            slug: user.slug
          })

        {:error, _reason} ->
          conn
          |> put_status(:unauthorized)
          |> json(%{error: "Invalid or expired session"})
      end
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "No session found"})
    end
  end

  def create(conn, %{"user" => user_params, "kingdom" => kingdom_params, "leader_protagonist" => leader_protagonist_params}) do
    case Accounts.register_user(user_params, kingdom_params, leader_protagonist_params) do
      {:ok, %{user: user, kingdom: kingdom, protagonist: protagonist}} ->
        conn
        |> put_status(:created)
        |> json(%{
          user: %{
            id: user.id,
            nickname: user.nickname,
            email: user.email,
            slug: user.slug
          },
          kingdom: %{
            id: kingdom.id,
            name: kingdom.name
          },
          protagonist: %{
            id: protagonist.id,
            name: protagonist.name
          }
        })

      {:error, failed_operation, chagneset, _changes_so_far} ->
        # Transform errors to JSON
        errors = Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
            inspect(get_in(opts, [String.to_existing_atom(key)]))
          end)
        end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Registration failed at step: #{failed_operation}",
          details: errors
        })

    end
  end
end
