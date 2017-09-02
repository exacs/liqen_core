defmodule LiqenCore.Repo.Migrations.CreateQuestionsTags do
  use Ecto.Migration

  def change do
    create table(:questions_tags) do
      add :question_id, references(:questions)
      add :tag_id, references(:tags)
      add :required, :boolean

      timestamps()
    end
  end
end
