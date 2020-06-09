defmodule Lumber.Repo.Migrations.CreateContests do
  use Ecto.Migration

  def change do
    create table(:contests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :starts_at, :utc_datetime, null: false
      add :ends_at, :utc_datetime, null: false
      add :submissions_before, :utc_datetime, null: false
      add :type, :string, null: false

      timestamps()
    end
  end
end
