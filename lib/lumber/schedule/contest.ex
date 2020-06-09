defmodule Lumber.Schedule.Contest do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contests" do
    has_many :wwsac_submissions, Lumber.Wwsac.Submission

    field :starts_at, :utc_datetime
    field :ends_at, :utc_datetime
    field :submissions_before, :utc_datetime
    field :title, :string
    field :type, :string

    timestamps()
  end
end
