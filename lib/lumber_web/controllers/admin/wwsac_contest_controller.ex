defmodule LumberWeb.Admin.WwsacContestController do
  use LumberWeb, :controller

  alias Lumber.Wwsac
  alias Lumber.WwsacAdmin

  def index(conn, _) do
    conn
    |> assign(:contests, WwsacAdmin.get_previous_contests())
    |> render()
  end

  def show(conn, %{"id" => id}) do
    contest = WwsacAdmin.get_contest_and_submissions(id)
    new_sub = Wwsac.build_wwsac_submission(contest)

    conn
    |> assign(:contest, contest)
    |> assign(:upload_changeset, Wwsac.new_wwsac_submission_changeset(new_sub))
    |> render()
  end

  def emails(conn, %{"id" => id}) do
    contest = WwsacAdmin.get_contest(id)
    filename = "wwsac-emails-" <> Timex.format!(contest.starts_at, "{YYYY}-{0M}-{0D}") <> ".txt"

    text =
      id
      |> WwsacAdmin.get_contest_requested_emails()
      |> Enum.join("\n")
      |> Kernel.<>("\n")

    conn
    |> put_resp_content_type("text/plain")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
    |> text(text)
  end
end
