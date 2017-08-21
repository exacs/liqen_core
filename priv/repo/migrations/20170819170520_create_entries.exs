defmodule LiqenCore.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :title, :string
      add :entry_type, :string

      timestamps()
    end
  end
end
