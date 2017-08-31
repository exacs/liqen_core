defmodule LiqenCore.Accounts do
  import Ecto.Query, only: [from: 2]
  alias LiqenCore.Accounts.{User,
                            PasswordCredential,
                            MediumCredential}
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
    |> get_password_credential()
    |> check_password(password)
    |> get_user_by_credential()
    |> create_token()
  end

  @doc """
  Get a password credential given an e-mail address
  """
  @spec get_password_credential(String.t) :: {:ok, map} | {:error, :unauthorized}
  def get_password_credential(email) do
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

  @doc """
  Check if a given password matches with the valid one stored in a
  PasswordCredential object
  """
  @spec check_password(any, String.t) :: {:ok, map} | {:error, :unauthorized}
  def check_password({:ok, credential}, password) do
    with {:error, _} <- Comeonin.Bcrypt.check_pass(credential, password) do
      {:error, :unauthorized}
    end
  end
  def check_password(any, _), do: any

  @doc """
  Get a user given its credential
  """
  def get_user_by_credential({:ok, credential}) do
    credential = Repo.preload(credential, :user)
    {:ok, credential.user}
  end
  def get_user_by_credential(any), do: any

  @doc """
  Create a token from a User object
  """
  def create_token({:ok, %User{} = user}) do
    Guardian.encode_and_sign(user, :access)
  end
  def create_token(any), do: any

  @doc """
  Authenticate a user via medium giving a `state` and a `code`

  To get both `state` and `code`, use `get_medium_login_data/0` or
  `get_medium_login_data/1`
  """
  def login_with_medium(state, code) do
    state
    |> get_medium_credential_from_state()
    |> get_long_lived_token(code)
    |> get_medium_user_data()
    |> update_medium_data()
    |> ensure_user_exists()
    |> create_token()
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
    state = Base.encode16(:crypto.strong_rand_bytes(8))

    %MediumCredential{state: state}
    |> Ecto.Changeset.change()
    |> Repo.insert()

    # Leave all the fields empty
    state
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
    state = Base.encode16(:crypto.strong_rand_bytes(8))

    case Repo.get_by(MediumCredential, user_id: user_id) do
      nil -> %MediumCredential{user_id: user_id}
      credential -> credential
    end
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:state, state)
    |> Repo.insert_or_update!()

    state
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

  @doc """
  Retrieve a MediumCredential
  """
  defp get_medium_credential_from_state(state) do
    case Repo.get_by(MediumCredential, state: state) do
      nil -> {:error, :not_found}
      credential -> {:ok, credential}
    end
  end

  @doc """
  Request a Medium Long-lived token from its API
  """
  def get_long_lived_token({:ok, credential}, code) do
    uri = "https://api.medium.com/v1/tokens"
    body = [
      code: code,
      client_id: System.get_env("MEDIUM_CLIENT_ID"),
      client_secret: System.get_env("MEDIUM_CLIENT_SECRET"),
      grant_type: "authorization_code",
      redirect_uri: System.get_env("MEDIUM_REDIRECT_URI")
    ]

    headers = %{
      "Content-Type" => "application/x-www-form-urlencoded",
      "Accept" => "application/json"
    }

    with {:ok, %{"access_token" => access_token}} <-
      uri
      |> HTTPoison.post({:form, body}, headers)
      |> handle_json_response(201)
    do
      {:ok, credential, access_token}
    end
  end
  def get_long_lived_token(any, _), do: any

  @doc """
  Get current user data from a Medium Token
  """
  def get_medium_user_data({:ok, credential, access_token}) do
    uri = "https://api.medium.com/v1/me"
    headers = %{
      "Content-Type" => "application/json",
      "Accept" => "application/json",
      "Authorization" => "Bearer #{access_token}"
    }
    with {:ok, %{"data" => data}} <-
      uri
      |> HTTPoison.get(headers)
      |> handle_json_response(200)
    do
      {:ok, credential, data}
    end
  end
  def get_medium_user_data(any), do: any

  defp handle_json_response({:ok, response}, status_code) do
    %{body: json_body,
      status_code: code} = response

    case code do
      ^status_code ->
        Poison.decode(json_body)
      _ ->
        {:error, json_body}
    end
  end
  defp handle_json_response(any, _), do: any

  @doc """
  Update a MediumCredential
  """
  def update_medium_data({:ok, new_credential, data}) do
    %{
      "id" => medium_id,
      "imageUrl" => image_url,
      "name" => name,
      "url" => url,
      "username" => username
    } = data

    attrs = %{
      medium_id: medium_id,
      username: username,
      name: name,
      url: url,
      image_url: image_url
    }

    case Repo.get_by(MediumCredential, medium_id: medium_id) do
      nil ->
        new_credential
        |> MediumCredential.changeset(attrs)
        |> Repo.update()

      old_credential ->
        old_credential
        |> MediumCredential.changeset(attrs)
        |> Repo.update()

    end
  end
  def update_medium_data(any), do: any

  @doc """
  Given a MediumCredential, creates a User if necessary
  """
  def ensure_user_exists({:ok, %MediumCredential{} = credential}) do
    %{user: user,
      username: username} = Repo.preload(credential, :user)

    params = %{
      username: username <> Base.encode16(:crypto.strong_rand_bytes(3))
    }

    case user do
      nil ->
        {:ok, user} =
          %User{}
          |> User.changeset(params)
          |> Repo.insert()

        credential
        |> Ecto.Changeset.change(user_id: user.id)
        |> Repo.update()

        {:ok, user}
      _ ->
        {:ok, user}
    end
  end
  def ensure_user_exists(any), do: any
end
