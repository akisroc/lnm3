defmodule PlatformWeb.HealthController do
  use PlatformWeb, :controller

  def health(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{
      message: "LNM3 Platform API is running and healthy."
    })
  end
end