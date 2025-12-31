defmodule Platform.Router do
  use Plug.Router

  plug :match
  plug Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason
  plug :dispatch

  get "/me" do
    token = get_auth_token(conn)

    # Appel gRPC au service Auth (Go)
    case Platform.AuthClient.validate(token) do
      {:ok, user_id} ->
        # Ici on renverra plus tard les données de la DB
        send_json(conn, 200, %{user_id: user_id, status: "online"})

      {:error, _reason} ->
        send_json(conn, 401, %{error: "Non autorisé"})
    end
  end

  defp get_auth_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> nil
    end
  end

  defp send_json(conn, status, body) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(body))
  end
end
