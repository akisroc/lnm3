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

  @doc """
  Create a complete account:
  User + Kingdom + Protagonist leading the Kingdom
  """
  def create(conn, %{
    "user" => %{"nickname" => user_nickname, "email" => user_email, "password" => user_password},
    "kingdom" => %{"name" => kingdom_name},
    "leader_protagonist" => %{"name" => leader_name}
  }) do
    registration_data = %{
      user_nickname: user_nickname,
      user_email: user_email,
      user_password: user_password,
      kingdom_name: kingdom_name,
      leader_name: leader_name
    }

    case Accounts.register_user(registration_data) do
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

      {:error, failed_operation, changeset, _changes_so_far} ->
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

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: "Invalid request structure",
      expected_structure: %{
        "user" => %{"nickname" => "John", "email" => "john@example.org", "password" => "abc123"},
        "kingdom" => %{"name" => "Mordor"},
        "leader_protagonist" => %{"name" => "Sauron"}
      }
    })
  end
end
