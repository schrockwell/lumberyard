defmodule Lumber.WwsacAdmin do
  import Ecto.Query
  import Ecto.Changeset

  alias Lumber.Repo
  alias Lumber.Schedule.Contest
  alias Lumber.Wwsac
  alias Lumber.Wwsac.Submission
  alias Lumber.Wwsac.Changeset

  def change_submission(sub, params \\ %{}) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    sub
    |> cast(params, [
      :age_group,
      :callsign,
      :email,
      :power_level,
      :send_notifications,
      :prefix_count,
      :qso_count,
      :qso_points,
      :final_score
    ])
    |> validate_required([
      :age_group,
      :callsign,
      :email,
      :power_level,
      :final_score
    ])
    |> Changeset.trim_field(:email)
    |> Changeset.update_callsign(:callsign)
    |> Changeset.validate_age_group()
    |> Changeset.validate_power_level()
    |> change(modified_at: now, completed_at: now)
  end

  def create_or_update_submission(sub, params) do
    sub
    |> change_submission(params)
    |> Repo.insert_or_update()
    |> case do
      {:ok, sub} ->
        sub |> other_submissions_query() |> Repo.delete_all()
        {:ok, sub}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp other_submissions_query(sub) do
    from(s in Submission,
      where: s.contest_id == ^sub.contest_id,
      where: s.callsign == ^sub.callsign,
      where: s.id != ^sub.id
    )
  end

  def get_previous_contests do
    from(c in Contest,
      where: c.type == "WWSAC",
      where: c.starts_at <= ^DateTime.utc_now(),
      order_by: [desc: c.starts_at]
    )
    |> Repo.all()
  end

  def get_contest_and_submissions(contest_id) do
    sub_preload =
      from(s in Submission,
        where: not is_nil(s.completed_at),
        order_by: s.completed_at
      )

    Contest
    |> Repo.get(contest_id)
    |> Repo.preload(wwsac_submissions: sub_preload)
  end

  def get_contest(contest_id) do
    Repo.get(Contest, contest_id)
  end

  def new_submission(contest_id) do
    contest = get_contest(contest_id)

    %Submission{
      contest: contest,
      contest_id: contest.id
    }

    # Ecto.build_assoc(contest, :wwsac_submissions)
  end

  def get_submission(id) do
    Submission
    |> Repo.get(id)
    |> Repo.preload(:contest)
    |> Wwsac.put_wwsac_log()
  end

  def reject_submission(id) do
    Submission
    |> Repo.get(id)
    |> change(rejected_at: DateTime.utc_now() |> DateTime.truncate(:second))
    |> Repo.update!()
  end

  def unreject_submission(id) do
    Submission
    |> Repo.get(id)
    |> change(rejected_at: nil)
    |> Repo.update!()
  end

  def get_contest_requested_emails(id) do
    from(s in Submission,
      where: s.contest_id == ^id,
      where: not is_nil(s.completed_at),
      where: s.send_notifications,
      select: s.email
    )
    |> Repo.all()
  end
end
