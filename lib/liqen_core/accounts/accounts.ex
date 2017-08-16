defmodule LiqenCore.Accounts do
  import Ecto.Query, only: [from: 2]
  alias LiqenCore.Accounts.{User, PasswordCredential}
  alias LiqenCore.Repo
  @moduledoc """
  Manages everything related to user accounts and its authentication.

  ## Notes

  - This module doesn't manage permissions or roles. It only gives an interface
    to handle with identities.
  - This module doesn't have any session mechanism like tokens.
  - This module defines a type `t:user/0` which is a "public" representation of
    a user. Functions that returns a user will return this `t:user/0`. Do not
    confuse with `LiqenCore.Accounts.User` which is an internal module.
  """

  @typedoc """
  Represents a user.

  ```
  %{
    id: "42",
    username: "tai",
    name: "Taichi Yagami"
  }
  ```
  """
  @type user :: %{
    id: number,
    username: String.t,
    name: String.t
  }

  @doc """
  Creates a user.
  """
  @spec create_user(map) :: {:ok, user} | {:error, Ecto.Changeset.t}
  def create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Ecto.Changeset.cast_assoc(
      :password_credential, with: &PasswordCredential.changeset/2)
    |> Repo.insert()
    |> take()
  end

  @doc """
  Get a user
  """
  def get_user(id) do
    User
    |> get(id)
    |> take()
  end

  @doc """
  List all users
  """
  def list_users do
    User
    |> get_all()
    |> take()
  end

  @doc """
  Authenticate a user giving a pair of email-password
  """
  def login_with_password(email, password) do
    email
    |> get_user_by_email()
    |> check_password(password)
    |> get_user_by_credential()
    |> take()

  end

  defp get_user_by_email(email) do
    query =
      from pc in PasswordCredential,
      where: pc.email == ^email

    case Repo.one(query) do
      %PasswordCredential{} = pc ->
        {:ok, pc}
      _ ->
        {:error, :unauthorized}
    end
  end

  defp check_password({:ok, credential}, password) do
    with {:error, _} <- Comeonin.Bcrypt.check_pass(credential, password) do
      {:error, :unauthorized}
    end
  end
  defp check_password(any), do: any

  defp get_user_by_credential({:ok, credential}) do
    credential = Repo.preload(credential, :user)
    {:ok, credential.user}
  end
  defp get_user_by_credential(any), do: any

  @doc """
  Authenticate a user via medium giving a `state` and a `code`

  To get both `state` and `code`, use `get_medium_login_data/0` or
  `get_medium_login_data/1`
  """
  def login_with_medium(state, code) do
    # Ensure that there is an MediumCredential with the `state`
    # Get that MediumCredential object

    # Get a long-lived access token
    # to do it, make a form-encoded POST request

    # On success, we will get a token
    # do GET https://api.medium.com/v1/me to get medium user data

    # Collect the "id", "username", "name", "url" and "imageUrl" fields.
    # Ensure that `MediumCredential.medium_id` is the same as `id` returned
    # in the previous step or blank

    # Update MediumCredential data (username, name, url and imageUrl) with the
    # collected

    # If the MediumCredential is already linked to a user, return that user

    # If not, create new a user with the data:
    # - username = collected username + MediumCredential.id (to ensure
    #   non-duplicates)
    # - name = collected name
    #
    # return the created new user
  end

  @doc """
  Get data needed to create a user from a medium identity: a `state` (returned directly
  by this function) and a `code`.

  To get the `code`, follow the steps in
  [Medium API documentation](https://github.com/Medium/medium-api-docs#2-authentication)
  to redirect the user to a page in your domain with a short-term authorization
  code.

  From that redirect_uri, collect the `state` and `code` and call
  `login_with_medium/2` to finish the process.
  """
  def get_medium_login_data do
    # Create a MediumCredential with a random generated "state"
    # Leave all the fields empty
  end

  @doc """
  Get data needed to log in a `user` via medium: a `state` (returned directly by
  this function) and a `code`.

  To get the `code`, follow the steps in
  [Medium API documentation](https://github.com/Medium/medium-api-docs#2-authentication)
  to redirect the user to a page in your domain with a short-term authorization
  code.

  From that redirect_uri, collect the `state` and `code` and call
  `login_with_medium/2`.
  """
  def get_medium_login_data(user_id) do
    # If the user has MediumCredential, refresh the `state` with a random
    # generated one.

    # Otherwise, create a MediumCredential with a random generated "state"
    # linked with `user`
  end

  defp take(list) when is_list(list) do
    list =
      list
      |> Enum.map(&take(&1))
      |> Enum.map(fn {:ok, obj} -> obj end)

    {:ok, list}
  end
  defp take({:ok, %User{} = object}) do
    {:ok, Map.take(object, [:id, :name, :username])}
  end
  defp take(any), do: any

  defp get(struct, id) do
    case Repo.get(struct, id) do
      %{} = object ->
        {:ok, object}

      _ ->
        {:error, :not_found}
    end
  end
  defp get_all(struct) do
    struct
    |> Repo.all()
    |> Enum.map(fn obj -> {:ok, obj} end)
  end
end
