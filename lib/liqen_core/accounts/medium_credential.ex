defmodule LiqenCore.Accounts.MediumCredential do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiqenCore.Accounts.{MediumCredential,
                            User}
  @moduledoc """
  LiqenCredential stores the information to identify a person using the
  information stored at Medium
  """

  schema "medium_credentials" do
    field :medium_id, :string
    field :username, :string
    field :name, :string
    field :url, :string
    field :image_url, :string
    field :state, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%MediumCredential{} = credential, attrs) do
    credential
    |> cast(attrs, [:medium_id, :username, :name, :url, :image_url])
  end
end
