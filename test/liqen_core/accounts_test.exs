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
end
