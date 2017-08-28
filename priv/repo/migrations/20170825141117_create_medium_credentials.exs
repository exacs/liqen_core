defmodule LiqenCore.Repo.Migrations.CreateMediumCredentials do
  use Ecto.Migration

  def change do
    create table(:medium_credentials) do
      add :medium_id, :string
      add :username, :string
      add :name, :string
      add :url, :string
      add :image_url, :string
      add :state, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:medium_credentials, [:user_id])
  end
end
