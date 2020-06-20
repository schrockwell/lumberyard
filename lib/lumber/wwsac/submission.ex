defmodule Lumber.Wwsac.Submission do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "wwsac_submissions" do
    belongs_to(:contest, Lumber.Schedule.Contest)

    # User submission
    field(:age_group, :string)
    field(:callsign, :string)
    field(:email, :string)
    field(:power_level, :string)
    field(:send_notifications, :boolean)
    field(:file_contents, :string)

    # Submission flow
    field(:completed_at, :utc_datetime)
    field(:rejected_at, :utc_datetime)
    field(:modified_at, :utc_datetime)

    # Scoring
    field(:prefix_count, :integer)
    field(:qso_count, :integer)
    field(:qso_points, :integer)
    field(:final_score, :integer)

    # Virtual
    field(:wwsac_log, :map, virtual: true)

    timestamps()
  end
end
