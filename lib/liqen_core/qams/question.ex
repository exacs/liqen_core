defmodule LiqenCore.QAMS.Question do
  use Ecto.Schema
  alias LiqenCore.QAMS.{Tag,
                        QuestionTag}

  @moduledoc """
  Question represents a question
  """

  schema "questions" do
    field :title, :string
    many_to_many :tags, Tag, join_through: QuestionTag

    timestamps()
  end
end
