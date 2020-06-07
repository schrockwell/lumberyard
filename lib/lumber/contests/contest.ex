defmodule Lumber.Contests.Contest do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contests" do
    has_many :wwsac_submissions, Lumber.Contests.WwsacSubmission

    field :started_at, :utc_datetime
    field :submissions_before, :utc_datetime
    field :title, :string
    field :type, :string

    timestamps()
  end
end
