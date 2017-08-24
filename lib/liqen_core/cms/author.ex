defmodule LiqenCore.CMS.Author do
  use Ecto.Schema

  @moduledoc """
  Author represents an author of content. Internally, one author is part of an user

  ## Fields

  - **role**. Privileges of the Author. TBD
  """
  schema "cms_authors" do
    field :role, :string

    timestamps()
  end
end
