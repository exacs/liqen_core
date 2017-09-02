defmodule LiqenCore.QAMS.Tag do
  use Ecto.Schema
  alias LiqenCore.QAMS.{Question,
                        QuestionTag}

  @moduledoc """
  Tag
  """

  schema "tags" do
    field :title, :string
    many_to_many :questions, Question, join_through: QuestionTag

    timestamps()
  end
end
