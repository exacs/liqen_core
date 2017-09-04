defmodule LiqenCore.QAMS.Annotation do
  use Ecto.Schema
  alias LiqenCore.QAMS.{Tag,
                        AnnotationTag}

  @moduledoc """
  Annotation represents a selection of an Entry with a Tag
  """

  schema "annotations" do
    many_to_many :tags, Tag, join_through: AnnotationTag
    belongs_to :entry, Entry

    timestamps()
  end
end
