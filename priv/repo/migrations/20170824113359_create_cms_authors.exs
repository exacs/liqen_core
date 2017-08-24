defmodule LiqenCore.Repo.Migrations.CreateCmsAuthors do
  use Ecto.Migration

  def change do
    create table(:cms_authors) do
      add :role, :string

      timestamps()
    end
  end
end
