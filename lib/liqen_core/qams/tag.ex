defmodule LiqenCore.QAMS.Tag do
  use Ecto.Schema
  alias LiqenCore.QAMS.{Question,
                        QuestionTag,
                        Annotation,
                        AnnotationTag}

  @moduledoc """
  Tag
  """

  schema "tags" do
    field :title, :string
    many_to_many :questions, Question, join_through: QuestionTag
    many_to_many :annotations, Annotation, join_trough: AnnotationTag

    timestamps()
  end
end
