defmodule Lumber.Wwsac do
  alias Lumber.Repo
  import Ecto.Changeset
  import Ecto.Query

  alias Lumber.Logs
  alias Lumber.Schedule.Contest
  alias Lumber.Wwsac.Submission

  def build_wwsac_submission do
    case get_next_wwsac_contest() do
      nil -> nil
      contest -> Ecto.build_assoc(contest, :wwsac_submissions)
    end
  end

  def get_wwsac_submission(id) do
    Submission
    |> Repo.get(id)
    |> Repo.preload(:contest)
    |> case do
      nil -> :error
      sub -> {:ok, sub}
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

  def new_wwsac_submission_changeset(submission, path \\ nil)

  def new_wwsac_submission_changeset(submission, nil) do
    submission
    |> change()
    |> add_error(:file, "is required")
  end

  def new_wwsac_submission_changeset(submission, path) do
    stat = File.stat!(path)

    if stat.size > 1_048_576 do
      submission
      |> change()
      |> add_error(:file, "is larger than 1 MB")
    else
      submission
      |> change(file_contents: File.read!(path))
      |> validate_required([:file_contents, :contest_id])
    end
  end

  def analyze_wwsac_submission_file_changeset(%{valid?: false} = changeset) do
    changeset
  end

  def analyze_wwsac_submission_file_changeset(%{valid?: true} = changeset) do
    contents = get_field(changeset, :file_contents)

    case Logs.guess_format(contents) do
      {:ok, :adif} ->
        log = HamRadio.ADIF.decode(contents)

        change(changeset,
          qso_count: length(log.contacts),
          callsign: guess_my_callsign(log)
        )

      {:ok, :cabrillo} ->
        # TODO
        changeset

      :error ->
        changeset
    end
  end

  defp guess_my_callsign(%{contacts: [contact | _rest]} = _log) do
    contact.fields["STATION_CALLSIGN"] || contact.fields["OPERATOR"]
  end

  defp guess_my_callsign(_), do: nil

  def prepare_wwsac_submission_changeset(submission, params \\ %{}) do
    submission
    |> cast(params, [:callsign, :email, :age_group, :power_level, :overlay])
    |> update_callsign(:callsign)
    |> trim_field(:email)
    |> validate_format(:email, ~r/@/, message: "is not a valid e-mail address")
    |> validate_required([
      :callsign,
      :email,
      :age_group,
      :power_level,
      :overlay,
      :file_contents,
      :contest_id
    ])
    |> validate_inclusion(:age_group, Enum.map(age_group_options(), &elem(&1, 1)))
    |> validate_inclusion(:power_level, Enum.map(power_level_options(), &elem(&1, 1)))
    |> validate_inclusion(:overlay, Enum.map(overlay_options(), &elem(&1, 1)))
  end

  def submit_wwsac_submission_changeset(submission) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    submission |> change(completed_at: now)
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
    Repo.insert_or_update(changeset)
  end

  def guess_submission_format(sub) do
    Logs.guess_format(sub.file_contents)
  end
end
