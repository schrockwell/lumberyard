defmodule Lumber.Wwsac do
  alias Lumber.Repo
  import Ecto.Changeset
  import Ecto.Query

  alias Lumber.Logs
  alias Lumber.Wwsac
  alias Lumber.Schedule.Contest
  alias Lumber.Wwsac.Submission

  alias HamRadio.Cabrillo
  alias HamRadio.ADIF

  @spec build_wwsac_submission(Contest.t()) :: Submission.t()
  def build_wwsac_submission(contest) do
    Ecto.build_assoc(contest, :wwsac_submissions)
  end

  def get_contest(id) do
    Repo.get(Contest, id)
  end

  @spec get_current_contest :: {:ok, Contest.t()} | :error
  def get_current_contest do
    Repo.one(
      from(c in Contest,
        where: c.type == "WWSAC",
        where: c.starts_at <= ^DateTime.utc_now(),
        # where: c.submissions_before >= ^DateTime.utc_now(),
        order_by: [desc: c.starts_at],
        limit: 1
      )
    )
    |> case do
      nil -> :error
      contest -> {:ok, contest}
    end
  end

  @spec get_most_recent_contest :: Contest.t() | nil
  def get_most_recent_contest do
    Repo.one(
      from(c in Contest,
        where: c.type == "WWSAC",
        where: c.starts_at <= ^DateTime.utc_now(),
        order_by: [desc: c.starts_at],
        limit: 1
      )
    )
  end

  @spec get_next_contest :: {:ok, Contest.t()} | :error
  def get_next_contest do
    Repo.one(
      from(c in Contest,
        where: c.type == "WWSAC",
        where: c.starts_at >= ^DateTime.utc_now(),
        where: c.submissions_before >= ^DateTime.utc_now(),
        order_by: c.starts_at,
        limit: 1
      )
    )
    |> case do
      nil -> :error
      contest -> {:ok, contest}
    end
  end

  def get_previous_contests do
    from(c in Contest,
      where: c.type == "WWSAC",
      where: c.starts_at <= ^DateTime.utc_now(),
      order_by: [desc: c.starts_at]
    )
    |> Repo.all()
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

  def put_wwsac_log(sub) do
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

  def age_group_options do
    [
      {"Please select...", ""},
      {"Youth YL (26 and under)", "YYL"},
      {"YL (over 26)", "YL"},
      {"Youth (26 and under)", "Y"},
      {"OM (over 26)", "OM"}
    ]
  end

  def power_level_options do
    [
      {"Please select...", ""},
      {"QRP (5W max)", "QRP"},
      {"Low Power (100W max)", "LP"},
      {"High Power (1,500W max)", "HP"}
    ]
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
      callsign: guess_my_callsign(log),
      power_level: guess_power_level(log),
      age_group: guess_age_group(log),
      email: guess_email(log)
    )
  end

  defp guess_my_callsign(%{contacts: [contact | _rest]} = _log) do
    contact.my_callsign
  end

  defp guess_my_callsign(_), do: nil

  # Cabrillo v3
  defp guess_power_level(%{source: %Cabrillo.Log{header_fields: %{"CATEGORY-POWER" => "HIGH"}}}),
    do: "HP"

  defp guess_power_level(%{source: %Cabrillo.Log{header_fields: %{"CATEGORY-POWER" => "LOW"}}}),
    do: "LP"

  defp guess_power_level(%{source: %Cabrillo.Log{header_fields: %{"CATEGORY-POWER" => "QRP"}}}),
    do: "QRP"

  # Cabrillo v2
  defp guess_power_level(%{source: %Cabrillo.Log{header_fields: %{"CATEGORY" => category}}}) do
    words = String.split(category, " ")

    cond do
      "HIGH" in words -> "HP"
      "LOW" in words -> "LP"
      "QRP" in words -> "QRP"
      true -> nil
    end
  end

  defp guess_power_level(_), do: nil

  defp guess_age_group(%{contacts: [contact | _rest]} = _log) do
    if contact.exchange_sent in ["OM", "YL", "Y", "YYL"] do
      contact.exchange_sent
    else
      nil
    end
  end

  defp guess_age_group(_), do: nil

  defp guess_email(%{source: %Cabrillo.Log{header_fields: %{"EMAIL" => email}}}), do: email
  defp guess_email(_), do: nil

  defp option_values(list) do
    Enum.map(list, &elem(&1, 1))
  end

  def prepare_wwsac_submission_changeset(submission, params \\ %{}) do
    submission
    |> cast(params, [:callsign, :email, :age_group, :power_level, :send_notifications])
    |> update_callsign(:callsign)
    |> trim_field(:email)
    |> validate_format(:email, ~r/@/, message: "is not a valid e-mail address")
    |> validate_required([
      :callsign,
      :email,
      :age_group,
      :power_level,
      :file_contents,
      :contest_id
    ])
    |> validate_inclusion(:age_group, option_values(age_group_options()))
    |> validate_inclusion(:power_level, option_values(power_level_options()))
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
