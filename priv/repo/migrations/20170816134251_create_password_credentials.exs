defmodule LiqenCore.Repo.Migrations.CreatePasswordCredentials do
  use Ecto.Migration

  def change do
    create table(:password_credentials) do
      add :email, :string
      add :encrypted_password, :string
      add :user_id, references(:users, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create unique_index(:password_credentials, [:email])
    create index(:password_credentials, [:user_id])
  end
end
