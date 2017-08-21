defmodule LiqenCore.CMS.ExternalHTML do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiqenCore.CMS.{ExternalHTML,
                       Entry}
  @moduledoc """
  ExternalHTML represents an entry that references an external HTML file

  ## Fields

  - **uri**. The location of the html file
  """

  schema "external_htmls" do
    field :uri, :string
    belongs_to :entry, Entry

    timestamps()
  end

  def changeset(%ExternalHTML{} = html, attrs) do
    html
    |> cast(attrs, [:uri])
    |> validate_required([:uri])
  end
end
