# defmodule Platform.AccountsTest do
#   use Platform.DataCase, async: true

#   alias Platform.Accounts
#   alias Platform.Accounts.User

#   import Platform.Fixtures

#   describe "register_user/1" do
#     test "creates user with valid attributes" do
#       attrs = valid_user_attributes()

#       assert {:ok, %User{} = user} = Accounts.register_user(attrs)
#       assert user.nickname == "testuser"
#       assert user.email == "test@example.com"
#       assert user.slug == "testuser"
#       assert user.is_enabled == true
#       assert user.is_removed == false
#       # Password should be hashed, not plain text
#       assert user.password != "securepassword123"
#       assert String.starts_with?(user.password, "$argon2")
#     end

#     test "generates unique slug from nickname" do
#       attrs = valid_user_attributes(%{nickname: "Test User"})

#       assert {:ok, user} = Accounts.register_user(attrs)
#       assert user.slug == "test-user"
#     end

#     test "requires nickname, email, and password" do
#       assert {:error, changeset} = Accounts.register_user(%{})
#       assert %{nickname: ["can't be blank"]} = errors_on(changeset)
#       assert %{email: ["can't be blank"]} = errors_on(changeset)
#       assert %{password: ["can't be blank"]} = errors_on(changeset)
#     end

#     test "validates email format" do
#       attrs = valid_user_attributes(%{email: "invalid-email"})

#       assert {:error, changeset} = Accounts.register_user(attrs)
#       assert %{email: [_]} = errors_on(changeset)
#     end

#     test "validates password length" do
#       attrs = valid_user_attributes(%{password: "short"})

#       assert {:error, changeset} = Accounts.register_user(attrs)
#       assert %{password: ["should be at least 8 character(s)"]} = errors_on(changeset)
#     end

#     test "validates nickname uniqueness" do
#       user = user_fixture(%{nickname: "uniqueuser"})
#       attrs = valid_user_attributes(%{nickname: "uniqueuser"})

#       assert {:error, changeset} = Accounts.register_user(attrs)
#       assert %{nickname: ["has already been taken"]} = errors_on(changeset)
#     end

#     test "validates email uniqueness" do
#       user = user_fixture(%{email: "unique@example.com"})
#       attrs = valid_user_attributes(%{email: "unique@example.com"})

#       assert {:error, changeset} = Accounts.register_user(attrs)
#       assert %{email: ["has already been taken"]} = errors_on(changeset)
#     end

#     test "trims and lowercases email" do
#       attrs = valid_user_attributes(%{email: "  TEST@EXAMPLE.COM  "})

#       assert {:ok, user} = Accounts.register_user(attrs)
#       assert user.email == "test@example.com"
#     end
#   end

#   describe "authenticate_user/2" do
#     setup do
#       user = user_fixture(%{
#         email: "auth@example.com",
#         password: "correctpassword"
#       })

#       {:ok, user: user}
#     end

#     test "authenticates user with valid credentials", %{user: user} do
#       assert {:ok, authenticated_user} =
#         Accounts.authenticate_user("auth@example.com", "correctpassword")

#       assert authenticated_user.id == user.id
#       assert authenticated_user.email == user.email
#     end

#     test "returns error with invalid password" do
#       assert {:error, :unauthorized} =
#         Accounts.authenticate_user("auth@example.com", "wrongpassword")
#     end

#     test "returns error with non-existent email" do
#       assert {:error, :unauthorized} =
#         Accounts.authenticate_user("nonexistent@example.com", "password")
#     end

#     test "returns error for disabled user" do
#       user = user_fixture(%{
#         email: "disabled@example.com",
#         password: "password123"
#       })

#       Repo.update!(User.changeset(user, %{is_enabled: false}))

#       assert {:error, :disabled} =
#         Accounts.authenticate_user("disabled@example.com", "password123")
#     end

#     test "returns error for removed user" do
#       user = user_fixture(%{
#         email: "removed@example.com",
#         password: "password123"
#       })

#       Repo.update!(User.changeset(user, %{is_removed: true}))

#       assert {:error, :removed} =
#         Accounts.authenticate_user("removed@example.com", "password123")
#     end
#   end
# end
