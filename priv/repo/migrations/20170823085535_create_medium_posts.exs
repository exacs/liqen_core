defmodule LiqenCore.Repo.Migrations.CreateMediumPosts do
  use Ecto.Migration

  def change do
    create table(:medium_posts) do
      add :title, :string
      add :uri, :string
      add :publishing_date, :utc_datetime
      add :license, :string
      add :tags, {:array, :string}
      add :entry_id, references(:entries), null: false

      timestamps()
    end
  end
end
