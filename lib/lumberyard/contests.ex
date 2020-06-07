defmodule Lumberyard.Contests do
  alias Lumberyard.Repo
  import Ecto.Changeset
  import Ecto.Query

  alias Lumberyard.Contests.{Contest}

  def build_wwsac_submission do
    case get_next_wwsac_contest() do
      nil -> nil
      contest -> Ecto.build_assoc(contest, :wwsac_submissions)
    end
  end

  def get_next_wwsac_contest do
    Repo.one(
      from(c in Contest,
        where: c.type == "WWSAC",
        where: c.started_at >= ^DateTime.utc_now(),
        limit: 1
      )
    )
  end

  def age_group_options do
    [
      {"Youth YL", "Youth YL"},
      {"YL", "YL"},
      {"Youth", "Youth"},
      {"OM", "OM"}
    ]
  end

  def power_level_options do
    [
      {"QRP (5W max)", "QRP"},
      {"Low Power (100W max)", "LP"},
      {"High Power (1,500W max)", "HP"}
    ]
  end

  def overlay_options do
    [{"None", "None"}, {"Youth YL", "Youth YL"}, {"YL", "YL"}, {"Youth", "Youth"}]
  end

  def new_wwsac_submission_changeset(submission, params \\ %{}) do
    submission
    |> cast(params, [:callsign, :email, :age_group, :power_level, :overlay])
    |> update_callsign(:callsign)
    |> trim_field(:email)
    |> validate_format(:email, ~r/@/, message: "is not a valid e-mail address")
    |> validate_required([:callsign, :email, :age_group, :power_level, :overlay])
    |> validate_inclusion(:age_group, Enum.map(age_group_options(), &elem(&1, 1)))
    |> validate_inclusion(:power_level, Enum.map(power_level_options(), &elem(&1, 1)))
    |> validate_inclusion(:overlay, Enum.map(overlay_options(), &elem(&1, 1)))
  end

  defp update_callsign(changeset, field) do
    changeset
    |> get_change(field)
    |> case do
      string when is_binary(string) ->
        put_change(changeset, field, normalize_callsign(string))

      _ ->
        changeset
    end
  end

  defp normalize_callsign(callsign) do
    callsign |> String.trim() |> String.upcase()
  end

  defp trim_field(changeset, field) do
    case get_change(changeset, field) do
      string when is_binary(string) ->
        put_change(changeset, field, String.trim(string))

      _ ->
        changeset
    end
  end

  def save_wwsac_submission(changeset) do
    Repo.insert(changeset)
  end
end
