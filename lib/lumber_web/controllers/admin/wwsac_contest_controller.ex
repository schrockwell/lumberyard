defmodule LumberWeb.Admin.WwsacContestController do
  use LumberWeb, :controller

  alias Lumber.WwsacAdmin

  def index(conn, _) do
    conn
    |> assign(:contests, WwsacAdmin.get_previous_contests())
    |> render()
  end

  def show(conn, %{"id" => id}) do
    conn
    |> assign(:contest, WwsacAdmin.get_contest_and_submissions(id))
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
