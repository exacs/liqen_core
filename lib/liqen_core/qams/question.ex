defmodule LiqenCore.QAMS.Question do
  use Ecto.Schema

  @moduledoc """
  Question represents a question
  """

  schema "questions" do
    field :title, :string

    timestamps()
  end
end
