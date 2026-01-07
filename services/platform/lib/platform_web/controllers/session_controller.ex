defmodule PlatformWeb.SessionController do
  use PlatformWeb, :controller

  def login(conn, %{"email" => email, "password" => password}) do
    case Platform.Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = Platform.Accounts.Session.generate_session_token(
          user,
          conn.remote_ip |> :inet.ntoa() |> to_string(),
          conn |> get_req_header("user-agent") |> List.first()
        )
        |> Base.url_encode64(padding: false)

        conn
        |> put_resp_cookie("_platform_user_token", token,
          http_only: true,
          secure: false,
          same_site: "Lax",
          domain: ".localhost",
          path: "/",
          max_age: Platform.Accounts.Session.session_validity_in_seconds()
        )
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
        |> json(%{error: "Invalid credentials"})
    end
  end


  def logout(conn, _params) do
    conn
    |> delete_resp_cookie("_platform_user_token",
      domain: ".localhost",
      path: "/"
    )
    |> put_status(:ok)
    |> json(%{message: "Logged out successfully"})
  end
end
