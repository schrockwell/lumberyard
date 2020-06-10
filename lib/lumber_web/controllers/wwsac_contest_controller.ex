defmodule LumberWeb.WwsacContestController do
  use LumberWeb, :controller

  alias Lumber.Wwsac
  alias Lumber.WwsacResults

  def index(conn, _) do
    show(conn, %{})
  end

  def show(conn, params) do
    contest =
      if params["id"] do
        Wwsac.get_contest(params["id"])
      else
        Wwsac.get_most_recent_contest()
      end

    conn
    |> assign(:contest, contest)
    |> assign(:results, WwsacResults.get_contest_results(contest))
    |> assign(:previous, Wwsac.get_previous_contests())
    |> render(:show)
  end
end
