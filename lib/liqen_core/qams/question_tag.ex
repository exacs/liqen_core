defmodule LiqenCore.QAMS.QuestionTag do
  use Ecto.Schema
  alias LiqenCore.QAMS.{Question,
                        Tag}

  @moduledoc """
  QuestionTag represents the many-to-many relation betweeen questions and tags
  """

  @primary_key false
  schema "questions_tags" do
    belongs_to :question, Question
    belongs_to :tag, Tag
    field :required, :boolean

    timestamps()
  end
end
