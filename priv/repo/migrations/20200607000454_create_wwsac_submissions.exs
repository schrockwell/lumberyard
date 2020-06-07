defmodule Lumber.Repo.Migrations.CreateWwsacSubmissions do
  use Ecto.Migration

  def change do
    create table(:wwsac_submissions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :callsign, :string, null: false
      add :email, :string, null: false
      add :age_group, :string, null: false
      add :power_level, :string, null: false
      add :overlay, :string, null: false
      add :qso_count, :integer
      add :qso_points, :integer
      add :prefix_count, :integer
      add :final_score, :integer
      add :send_notifications, :boolean, null: false, default: false
      add :contest_id, references(:contests, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:wwsac_submissions, [:contest_id])
  end
end
