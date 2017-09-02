defmodule LiqenCore.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    add :title, :string

    timestamps()
  end
end
