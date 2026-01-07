defmodule PlatformWeb.UserController do
  use PlatformWeb, :controller

  def me(conn, _params) do
    # Extract token from cookie
    token = conn.cookies["_platform_user_token"]

    if token do
      case Platform.Accounts.Session.get_user_by_session_token(token) do
        {:ok, user} ->
          conn
          |> put_status(:ok)
          |> json(%{
            id: user.id,
            username: user.username,
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

  def create(conn, %{"user" => user_params}) do
    case Platform.Accounts.register_user(user_params) do
      {:ok, user} ->
      conn
      |> put_status(:created)
      |> json(%{message: "User created", slug: user.slug})

    {:error, %Ecto.Changeset{} = changeset} ->
      errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        # Transform error to JSON
        Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
          inspect(get_in(opts, [String.to_existing_atom(key)]))
        end)
      end)

      conn
      |> put_status(:unprocessable_entity)
      |> json(%{errors: errors})
    end
  end
end
