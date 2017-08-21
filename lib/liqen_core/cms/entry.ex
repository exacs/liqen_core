defmodule LiqenCore.CMS.Entry do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiqenCore.CMS.{Entry,
                       ExternalHTML}
  @moduledoc """
  Entry represents a piece of content.

  ## Fields

  - **title**. Human readable title of the entry
  - **entry_type**. Type of the entry
  """

  schema "entries" do
    field :title, :string
    field :entry_type, :string
    has_one :external_html, ExternalHTML

    timestamps()
  end

  def changeset(%Entry{} = entry, attrs) do
    entry
    |> cast(attrs, [:title, :entry_type])
    |> validate_required([:title])
    |> validate_inclusion(:entry_type, ["external_html", "medium"])
  end
end
