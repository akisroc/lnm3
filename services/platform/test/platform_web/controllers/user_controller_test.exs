defmodule PlatformWeb.UserControllerTest do
  use PlatformWeb.ConnCase, async: true

  alias PlatformInfra.AccountsFixtures
  alias PlatformInfra.Database.Schemas.User

  alias PlatformInfra.Database.Types.Slug

  describe "POST /register" do
    test "creates user with valid data", %{conn: conn} do
      params = %{
        user: %{nickname: "newuser", email: "newuser@example.com", password: "securepassword123"},
        kingdom: %{name: "Mordor"},
        leader_protagonist: %{name: "Sauron"}
      }

      conn = post(conn, ~p"/register", params)

      assert %{
        "user" => %{
          "id" => user_id,
          "nickname" => "newuser",
          "email" => "newuser@example.com",
          "slug" => user_slug
        },
        "kingdom" => %{
          "id" => _kingdom_id,
          "name" => "Mordor"
        },
        "protagonist" => %{
          "id" => _protagonist_id,
          "name" => "Sauron"
        }
      } = json_response(conn, 201)

      expected_user_slug = Slug.generate(user_id, "newuser")
      assert user_slug === expected_user_slug
    end

    # test "returns errors with invalid data", %{conn: conn} do
    #   user_params = %{
    #     nickname: "",
    #     email: "invalid-email",
    #     password: "short"
    #   }

    #   conn = post(conn, ~p"/register", user: user_params)

    #   assert %{"errors" => errors} = json_response(conn, 422)
    #   assert Map.has_key?(errors, "nickname")
    #   assert Map.has_key?(errors, "email")
    #   assert Map.has_key?(errors, "password")
    # end

    # test "returns error when email already exists", %{conn: conn} do
    #   _existing_user = AccountsFixtures.user_fixture(%{email: "taken@example.com"})

    #   user_params = %{
    #     nickname: "differentuser",
    #     email: "taken@example.com",
    #     password: "securepassword123"
    #   }

    #   conn = post(conn, ~p"/register", user: user_params)

    #   assert %{"errors" => %{"email" => _}} = json_response(conn, 422)
    # end

    # test "returns error when nickname already exists", %{conn: conn} do
    #   _existing_user = AccountsFixtures.user_fixture(%{nickname: "takenuser"})

    #   user_params = %{
    #     nickname: "takenuser",
    #     email: "different@example.com",
    #     password: "securepassword123"
    #   }

    #   conn = post(conn, ~p"/register", user: user_params)

    #   assert %{"errors" => %{"nickname" => _}} = json_response(conn, 422)
    # end

    # test "hashes password before storing", %{conn: conn} do
    #   user_params = %{
    #     nickname: "secureuser",
    #     email: "secure@example.com",
    #     password: "myplaintextpassword"
    #   }

    #   conn = post(conn, ~p"/register", user: user_params)

    #   assert json_response(conn, 201)

    #   # Verify password is hashed in database
    #   user = PlatformInfra.Repo.get_by(User, email: "secure@example.com")
    #   refute user.password == "myplaintextpassword"
    #   assert String.starts_with?(user.password, "$argon2")
    # end
  end
end
