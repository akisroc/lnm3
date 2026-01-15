defmodule PlatformInfra.AccountsFixtures do
  alias PlatformInfra.Database.Accounts

  @moduledoc """
  Test fixtures for creating test data.
  """

  @doc """
  Creates a user with valid attributes.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        nickname: "testuser#{System.unique_integer([:positive])}",
        email: "user#{System.unique_integer([:positive])}@example.com",
        password: "password123456"
      })
      |> Accounts.register_user()

    user
  end

  @doc """
  Returns valid user attributes for testing.
  """
  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      nickname: "testuser",
      email: "test@example.com",
      password: "securepassword123"
    })
  end
end
