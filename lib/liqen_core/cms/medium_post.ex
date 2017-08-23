defmodule LiqenCore.CMS.MediumPost do
  use Ecto.Schema
  import Ecto.Changeset
  alias LiqenCore.CMS.{MediumPost,
                       Entry}
  @moduledoc """
  MediumPost represents an entry that references an article published on Medium

  ## Fields

  - **title**. Title of the article in Medium
  - **uri**. URI of the article
  - **publishing_date**. Date when the publishing has been created on Medium
  - **license**. License of the article
  - **tags**. List of tags of the article
  - **copyright_cesion**. True if the author of the entry accepts that it is the
    copyright owner of the article and that Liqen could use it
  """

  schema "medium_posts" do
    field :title, :string
    field :uri, :string
    field :publishing_date, :utc_datetime
    field :license, :string
    field :tags, {:array, :string}
    field :copyright_cesion, :boolean, virtual: true
    belongs_to :entry, Entry

    timestamps()
  end

  def changeset(%MediumPost{} = post, attrs) do
    post
    |> cast(attrs, [:title,
                   :uri,
                   :publishing_date,
                   :license,
                   :tags,
                   :copyright_cesion])
    |> validate_required([:title,
                         :uri,
                         :publishing_date,
                         :tags,
                         :copyright_cesion])
    |> validate_acceptance(:copyright_cesion)
  end
end
