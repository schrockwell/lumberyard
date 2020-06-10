defmodule Lumber.WwsacAdmin do
  import Ecto.Query
  import Ecto.Changeset

  alias Lumber.Repo
  alias Lumber.Schedule.Contest
  alias Lumber.Wwsac.Submission
  alias Lumber.Wwsac

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
      from(s in Submission, where: not is_nil(s.completed_at), order_by: s.completed_at)

    Contest
    |> Repo.get(contest_id)
    |> Repo.preload(wwsac_submissions: sub_preload)
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
end
