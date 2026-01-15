# defmodule PlatformWeb.SessionControllerTest do
#   use PlatformWeb.ConnCase, async: true

#   import Ecto.Query

#   alias PlatformInfra.AccountsFixtures
#   alias PlatformInfra.Repo
#   alias PlatformInfra.Database.Accounts
#   alias PlatformInfra.Database.Entities.{User, Session}

#   describe "POST /login" do
#     setup do
#       user = AccountsFixtures.user_fixture(%{
#          nickname: "loginuser",
#         email: "login@example.com",
#         password: "correctpassword123"
#       })

#       {:ok, user: user}
#     end

#     test "logs in user with valid credentials", %{conn: conn, user: user} do
#       conn = post(conn, ~p"/login", %{
#         email: "login@example.com",
#         password: "correctpassword123"
#       })

#       assert %{
#         "token" => token,
#         "user_id" => user_id,
#         "user_email" => "login@example.com",
#         "user_slug" => "loginuser"
#       } = json_response(conn, 200)

#       assert user_id == user.id
#       assert is_binary(token)

#       # Check cookie is set
#       assert conn.resp_cookies["_platform_user_token"]
#       cookie = conn.resp_cookies["_platform_user_token"]
#       assert cookie.http_only == true
#       assert cookie.max_age == Accounts.session_validity_in_seconds()
#     end

#     test "returns error with invalid password", %{conn: conn} do
#       conn = post(conn, ~p"/login", %{
#         email: "login@example.com",
#         password: "wrongpassword"
#       })

#       assert %{"error" => "Invalid credentials"} = json_response(conn, 401)
#     end

#     test "returns error with non-existent email", %{conn: conn} do
#       conn = post(conn, ~p"/login", %{
#         email: "nonexistent@example.com",
#         password: "somepassword"
#       })

#       assert %{"error" => "Invalid credentials"} = json_response(conn, 401)
#     end

#     test "returns error for disabled user", %{conn: conn, user: user} do
#       Repo.update!(
#         User.create_changeset(user, %{is_enabled: false})
#       )

#       conn = post(conn, ~p"/login", %{
#         email: "login@example.com",
#         password: "correctpassword123"
#       })

#       assert %{"error" => "Invalid credentials"} = json_response(conn, 401)
#     end

#     # Todo: Unique on fields doesn’t concern removed users
#     test "returns error for removed user", %{conn: conn, user: user} do
#       Repo.update!(
#         User.create_changeset(user, %{is_removed: true})
#       )

#       conn = post(conn, ~p"/login", %{
#         email: "login@example.com",
#         password: "correctpassword123"
#       })

#       assert %{"error" => "Invalid credentials"} = json_response(conn, 401)
#     end

#     test "creates session in database", %{conn: conn, user: user} do
#       conn = post(conn, ~p"/login", %{
#         email: "login@example.com",
#         password: "correctpassword123"
#       })

#       assert json_response(conn, 200)

#       # Verify session was created
#       sessions = Repo.all(
#         from s in Session,
#         where: s.user_id == ^user.id
#       )

#       assert length(sessions) == 1
#       session = List.first(sessions)
#       assert session.context == "session"
#       assert session.ip_address != nil
#     end

#     test "stores hashed token in database", %{conn: conn} do
#       conn = post(conn, ~p"/login", %{
#         email: "login@example.com",
#         password: "correctpassword123"
#       })

#       response = json_response(conn, 200)
#       token = response["token"]

#       # Token in DB should be hashed, not the raw base64 token
#       session = Repo.one(Session)
#       refute session.token == token
#       refute session.token == Base.url_decode64!(token, padding: false)
#     end
#   end
# end
