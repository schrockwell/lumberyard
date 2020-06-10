defmodule LumberWeb.PageController do
  use LumberWeb, :controller

  alias Lumber.Wwsac

  plug :assign_next_contest

  def index(conn, _) do
    case Wwsac.get_current_contest() do
      nil ->
        conn
        |> assign(:contest, nil)
        |> assign(:changeset, nil)
        |> render()

      contest ->
        sub = Wwsac.build_wwsac_submission(contest)

        conn
        |> assign(:page_title, "Home")
        |> assign(:contest, contest)
        |> assign(
          :changeset,
          Wwsac.new_wwsac_submission_changeset(sub)
        )
        |> render()
    end
  end

  defp assign_next_contest(conn, _) do
    case Wwsac.get_next_contest() do
      {:ok, contest} -> assign(conn, :next_contest, contest)
      :error -> assign(conn, :next_contest, nil)
    end
  end
end
