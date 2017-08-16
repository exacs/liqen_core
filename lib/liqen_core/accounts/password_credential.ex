defmodule LiqenCore.Accounts.PasswordCredential do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiqenCore.Accounts.PasswordCredential
  @moduledoc """
  PasswordCredential represents a pair of e-mail and password to authenticate
  a user

  ## Fields

  - **e-mail**
  - **password**
  """

  schema "password_credentials" do
    field :email, :string
    field :password, :string, virtual: true
    field :crypted_password, :string

    timestamps()
  end

  @doc false
  def changeset(%PasswordCredential{} = credential, attrs) do
    credential
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
