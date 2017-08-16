defmodule LiqenCore.Accounts.PasswordCredential do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiqenCore.Accounts.{PasswordCredential, User}
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
    field :encrypted_password, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%PasswordCredential{} = credential, attrs) do
    credential
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> put_crypted_password()
  end

  defp put_crypted_password(%Ecto.Changeset{valid?: true} = changeset) do
    password = get_change(changeset, :password)

    changeset
    |> put_change(:encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
  end
  defp put_crypted_password(any), do: any
end
