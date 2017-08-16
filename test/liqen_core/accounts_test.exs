defmodule LiqenCore.AccountsTest do
  use LiqenCore.DataCase
  alias LiqenCore.Accounts
  alias LiqenCore.Accounts.User

  test "Create a valid user" do
    valid_params = %{
      username: "matt",
      name: "Yamato Ishida"
    }

    assert {:ok, user} = Accounts.create_user(valid_params)

    expected = %{
      id: user.id,
      username: "matt",
      name: "Yamato Ishida"
    }
    assert expected == user
  end

  test "Fail to create a user without some parameters" do
    empty_params = %{
      username: ""
    }

    assert {:error, changeset} = Accounts.create_user(empty_params)
    assert %{username: _} = errors_on(changeset)
  end

  test "Fail to create a user because its name is taken" do
    taken_params = %{
      username: "matt",
      name: "Yamato Ishida"
    }

    Repo.insert(%User{username: "matt", name: "Yamato Ishida"})

    assert {:error, changeset} = Accounts.create_user(taken_params)
    assert %{username: _} = errors_on(changeset)
  end

  test "Get an existing user" do
    {:ok, inserted_user} = Repo.insert(%User{username: "matt", name: "Yamato Ishida"})

    expected = %{
      id: inserted_user.id,
      username: "matt",
      name: "Yamato Ishida"
    }
    assert {:ok, returned} = Accounts.get_user(inserted_user.id)
    assert returned == expected
  end

  test "Fail to get a non-existing user" do
    Repo.insert(%User{username: "matt", name: "Yamato Ishida"})

    assert {:error, :not_found} == Accounts.get_user(0)
  end

  test "Get all users when there is no user" do
    assert {:ok, []} == Accounts.list_users()
  end

  test "Get all users" do
    {:ok, u1} = Repo.insert(%User{username: "matt", name: "Yamato Ishida"})
    {:ok, u2} = Repo.insert(%User{username: "sora", name: "Sora Takenouchi"})

    e1 = %{id: u1.id, username: "matt", name: "Yamato Ishida"}
    e2 = %{id: u2.id, username: "sora", name: "Sora Takenouchi"}
    assert {:ok, list} = Accounts.list_users()

    assert Enum.member?(list, e1)
    assert Enum.member?(list, e2)
  end
end
