defmodule LiqenCore.QAMS.AnnotationTag do
  use Ecto.Schema
  alias LiqenCore.QAMS.{Annotation,
                        Tag}

  @moduledoc """
  AnnotationTag represents the many-to-many relation between annotations and
  tags
  """

  @primary_key false
  schema "annotations_tags" do
    belongs_to :annotation, Annotation
    belongs_to :tag, Tag

    timestamps()
  end
end
