defmodule LiqenCore.Repo.Migrations.CreateExternalHtmls do
  use Ecto.Migration

  def change do
    create table(:external_htmls) do
      add :uri, :string
      add :entry_id, references(:entries), null: false

      timestamps()
    end
  end
end
