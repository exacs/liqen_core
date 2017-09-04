defmodule LiqenCore.QAMS.Answer do
  use Ecto.Schema
  alias LiqenCore.QAMS.{Annotation,
                        Question

  @moduledoc """
  Answer represents an answer to a question
  """

  schema "answers" do
    has_many :annotations, Annotation
    belongs_to :question, Question

    timestamps()
  end
end
