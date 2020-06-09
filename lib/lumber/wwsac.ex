defmodule Lumber.Wwsac do
  alias Lumber.Repo
  import Ecto.Changeset
  import Ecto.Query

  alias Lumber.Logs
  alias Lumber.Wwsac
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
      sub -> {:ok, sub |> put_wwsac_log()}
    end
  end

  defp put_wwsac_log(sub) do
    %{sub | wwsac_log: Wwsac.Log.from_file_contents(sub.file_contents)}
  end

  def count_other_wwsac_submissions(sub) do
    from(s in Submission,
      where: s.contest_id == ^sub.contest_id,
      where: s.callsign == ^sub.callsign,
      where: not is_nil(s.completed_at),
      select: s.id
    )
    |> Repo.aggregate(:count)
  end

  def get_next_wwsac_contest do
    Repo.one(
      from(c in Contest,
        where: c.type == "WWSAC",
        where: c.submissions_before >= ^DateTime.utc_now(),
        order_by: c.submissions_before,
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
    log =
      changeset
      |> get_field(:file_contents)
      |> Wwsac.Log.from_file_contents()

    change(changeset,
      qso_count: length(log.contacts),
      qso_points: log.total_contact_points,
      prefix_count: log.total_prefixes,
      final_score: log.final_score,
      callsign: guess_my_callsign(log)
    )
  end

  defp guess_my_callsign(%{contacts: [contact | _rest]} = _log) do
    contact.my_callsign
  end

  defp guess_my_callsign(_), do: nil

  defp option_values(list) do
    Enum.map(list, &elem(&1, 1))
  end

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
    |> validate_inclusion(:age_group, option_values(age_group_options()))
    |> validate_inclusion(:power_level, option_values(power_level_options()))
    |> validate_inclusion(:overlay, option_values(overlay_options()))
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

  def submit_wwsac_submission(changeset) do
    changeset
    |> save_wwsac_submission()
    |> case do
      {:ok, sub} ->
        delete_other_submissions(sub)
        {:ok, sub}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp delete_other_submissions(sub) do
    from(s in Submission,
      where: s.contest_id == ^sub.contest_id,
      where: s.callsign == ^sub.callsign,
      where: s.id != ^sub.id
    )
    |> Repo.delete_all()
  end

  def cancel_wwsac_submission(sub) do
    Repo.delete!(sub)
  end

  def guess_submission_format(sub) do
    Logs.guess_format(sub.file_contents)
  end
end
