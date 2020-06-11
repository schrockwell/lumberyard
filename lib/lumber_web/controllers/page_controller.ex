defmodule LumberWeb.PageController do
  use LumberWeb, :controller

  alias Lumber.Wwsac

  plug :assign_next_contest

  def index(conn, _) do
    conn
    |> LumberWeb.WwsacSubmissionController.assign_upload_form()
    |> assign(:page_title, "Home")
    |> render()
  end

  defp assign_next_contest(conn, _) do
    case Wwsac.get_next_contest() do
      {:ok, contest} -> assign(conn, :next_contest, contest)
      :error -> assign(conn, :next_contest, nil)
    end
  end
end
