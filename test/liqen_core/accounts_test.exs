defmodule LiqenCore.AccountsTest do
  use LiqenCore.DataCase
  alias LiqenCore.Accounts
  alias LiqenCore.Accounts.User

  @params_matt %{
    username: "matt",
    name: "Yamato Ishida"
  }
  @params_sora %{
    username: "sora",
    name: "Sora Takenouchi"
  }

  @params_matt_pc %{
    email: "matt@digimon.jp",
    password: "gabumon"
  }

  defp insert_user(params) do
    Repo.insert(Map.merge(%User{}, params))
  end

  test "Create a valid user" do
    assert {:ok, returned} = Accounts.create_user(@params_matt)

    expected = Map.put(@params_matt, :id, returned.id)
    assert expected == returned
  end

  test "Fail to create a user without some parameters" do
    empty_params = %{
      username: ""
    }

    assert {:error, changeset} = Accounts.create_user(empty_params)
    assert %{username: _} = errors_on(changeset)
  end

  test "Fail to create a user because its name is taken" do
    insert_user(@params_matt)
    taken_params = Map.put(@params_matt, :name, "I am not Matt")

    assert {:error, changeset} = Accounts.create_user(taken_params)
    assert %{username: _} = errors_on(changeset)
  end

  test "Get an existing user" do
    {:ok, inserted} = insert_user(@params_matt)
    expected = Map.put(@params_matt, :id, inserted.id)

    assert {:ok, returned} = Accounts.get_user(inserted.id)
    assert returned == expected
  end

  test "Fail to get a non-existing user" do
    insert_user(@params_matt)
    insert_user(@params_sora)

    assert {:error, :not_found} == Accounts.get_user(0)
  end

  test "Get all users when there is no user" do
    assert {:ok, []} == Accounts.list_users()
  end

  test "Get all users" do
    {:ok, u1} = insert_user(@params_matt)
    {:ok, u2} = insert_user(@params_sora)

    e1 = Map.put(@params_matt, :id, u1.id)
    e2 = Map.put(@params_sora, :id, u2.id)

    assert {:ok, list} = Accounts.list_users()

    assert Enum.member?(list, e1)
    assert Enum.member?(list, e2)
  end

  test "Create a user with credentials" do
    user = Map.put(@params_matt, :password_credential, @params_matt_pc)
    assert {:ok, returned} = Accounts.create_user(user)

    assert {:ok, returned} == Accounts.login_with_password(
      @params_matt_pc.email, @params_matt_pc.password
    )
  end

  test "Authenticate with a wrong password credential" do
    user = Map.put(@params_matt, :password_credential, @params_matt_pc)
    assert {:ok, _} = Accounts.create_user(user)
    assert {:error, :unauthorized} = Accounts.login_with_password(
      @params_matt_pc.email, "Pikachu"
    )
  end
end
