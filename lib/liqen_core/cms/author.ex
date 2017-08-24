defmodule LiqenCore.CMS.Author do
  use Ecto.Schema
  alias LiqenCore.CMS.Entry

  @moduledoc """
  Author represents an author of content. Internally, one author is part of an user

  ## Fields

  - **role**. Privileges of the Author. TBD
  """
  schema "cms_authors" do
    field :role, :string
    has_many :entries, Entry
    belongs_to :user, LiqenCore.Accounts.User

    timestamps()
  end
end
