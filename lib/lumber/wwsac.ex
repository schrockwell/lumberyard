defmodule Lumber.Wwsac do
  alias Lumber.Repo
  import Ecto.Changeset
  import Ecto.Query

  alias Lumber.Logs
  alias Lumber.Wwsac
  alias Lumber.Schedule.Contest
  alias Lumber.Wwsac.Submission
  alias Lumber.Wwsac.Changeset

  alias HamRadio.Cabrillo

  @spec build_wwsac_submission(Contest.t()) :: Submission.t()
  def build_wwsac_submission(contest) do
    Ecto.build_assoc(contest, :wwsac_submissions)
  end

  def get_contest(id) do
    Repo.get(Contest, id)
  end

  @spec get_current_contest :: Contest.t() | nil
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

  def put_wwsac_log(%{file_contents: nil} = sub), do: sub

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
    Changeset.age_group_options()
  end

  def power_level_options do
    Changeset.power_level_options()
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

    cond do
      is_nil(log) ->
        add_error(
          changeset,
          :wwsac_log,
          "The log file could not be read. Please use the ADIF or Cabrillo file formats."
        )

      Wwsac.Log.has_errors?(log) ->
        log
        |> Wwsac.Log.error_summaries()
        |> Enum.reduce(changeset, fn e, cs ->
          add_error(cs, :wwsac_log, e)
        end)

      true ->
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

  def prepare_wwsac_submission_changeset(submission, params \\ %{}) do
    submission
    |> cast(params, [:callsign, :email, :age_group, :power_level, :send_notifications])
    |> Changeset.update_callsign(:callsign)
    |> Changeset.trim_field(:email)
    |> validate_format(:email, ~r/@/, message: "is not a valid e-mail address")
    |> validate_required([
      :callsign,
      :email,
      :age_group,
      :power_level,
      :file_contents,
      :contest_id
    ])
    |> Changeset.validate_age_group()
    |> Changeset.validate_power_level()
  end

  def save_wwsac_submission(changeset) do
    Repo.insert_or_update(changeset)
  end

  def submit_wwsac_submission(changeset) do
    temp_sub = apply_changes(changeset)

    rejected_submission_count =
      temp_sub
      |> other_submissions_query()
      |> where([s], not is_nil(s.rejected_at))
      |> Repo.aggregate(:count)

    if rejected_submission_count > 0 do
      {:error,
       changeset
       |> Map.put(:action, :update)
       |> add_error(:callsign, "has been disqualified from this week's competition")}
    else
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      changeset
      |> change(completed_at: now)
      |> save_wwsac_submission()
      |> case do
        {:ok, sub} ->
          sub |> other_submissions_query() |> Repo.delete_all()
          {:ok, sub}

        {:error, changeset} ->
          {:error, changeset}
      end
    end
  end

  defp other_submissions_query(sub) do
    from(s in Submission,
      where: s.contest_id == ^sub.contest_id,
      where: s.callsign == ^sub.callsign,
      where: s.id != ^sub.id
    )
  end

  def cancel_wwsac_submission(sub) do
    Repo.delete!(sub)
  end

  def guess_submission_format(sub) do
    Logs.guess_format(sub.file_contents)
  end

  def __rescore_all__(opts \\ []) do
    query =
      from(s in Submission,
        where: not is_nil(s.completed_at),
        where: is_nil(s.rejected_at),
        select: s.id
      )

    query =
      if opts[:after] do
        from(s in query, where: s.completed_at > ^opts[:after])
      else
        query
      end

    sub_ids = Repo.all(query)

    results =
      sub_ids
      |> Task.async_stream(fn sub_id ->
        Submission
        |> Repo.get(sub_id)
        |> change()
        |> analyze_wwsac_submission_file_changeset()
        |> Repo.update()
        |> case do
          {:ok, _} -> {:ok, sub_id}
          {:error, _} -> {:error, sub_id}
        end
      end)
      |> Stream.map(&elem(&1, 1))
      |> Enum.to_list()

    ok_ids = Keyword.get_values(results, :ok)
    error_ids = Keyword.get_values(results, :error)

    IO.puts("OK - #{length(ok_ids)} submissions")
    IO.puts("Error - #{length(error_ids)} submissions: #{Enum.join(error_ids, ", ")}")
  end
end
