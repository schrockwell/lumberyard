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
end
