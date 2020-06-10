defmodule LumberWeb.WwsacLeaderboardController do
  use LumberWeb, :controller

  alias Lumber.WwsacResults

  def index(conn, _) do
    show(conn, %{})
  end

  def show(conn, params) do
    year =
      params
      |> Map.get("id", "#{DateTime.utc_now().year}")
      |> String.to_integer()

    conn
    |> assign(:leaderboards, WwsacResults.get_year_leaderboards(year))
    |> assign(:page_title, "#{year} Leaderboard")
    |> assign(:years, WwsacResults.all_years())
    |> assign(:year, year)
    |> render(:show)
  end
end
