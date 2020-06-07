defmodule Lumberyard.Contests.WwsacSubmission do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "wwsac_submissions" do
    belongs_to :contest, Lumberyard.Contests.Contest

    # User submission
    field :age_group, :string
    field :callsign, :string
    field :email, :string
    field :final_score, :integer
    field :overlay, :string
    field :power_level, :string
    field :send_notifications, :boolean

    # Scoring
    field :prefix_count, :integer
    field :qso_count, :integer
    field :qso_points, :integer

    timestamps()
  end
end
