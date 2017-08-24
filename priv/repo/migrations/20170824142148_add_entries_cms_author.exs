defmodule LiqenCore.Repo.Migrations.AddEntriesCmsAuthor do
  use Ecto.Migration

  def change do
    alter table (:entries) do
      add :author_id,
        references(:cms_authors)
    end
  end
end
