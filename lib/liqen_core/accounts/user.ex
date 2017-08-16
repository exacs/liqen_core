defmodule LiqenCore.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiqenCore.Accounts.{User, PasswordCredential}
  @moduledoc """
  User represents the essential identity of a user.

  Do not include data regarding authentication

  ## Fields

  - **username**. A chosen "nickname" unique per user
  - **name**. The real name of the user
  """

  schema "users" do
    field :username, :string
    field :name, :string
    has_one :password_credential, PasswordCredential

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :username])
    |> validate_required([:username])
    |> update_change(:username, &String.downcase/1)
    |> validate_format(:username, ~r/^[a-z0-9_]+$/)
    |> unique_constraint(:username)
  end
end
