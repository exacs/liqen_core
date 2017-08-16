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
end
