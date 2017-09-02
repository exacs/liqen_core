defmodule LiqenCore.QAMS.Tag do
  use Ecto.Schema

  @moduledoc """
  Tag
  """

  schema "tags" do
    field :title, :string

    timestamps()
  end
end
