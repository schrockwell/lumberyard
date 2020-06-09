defmodule LumberWeb.PageController do
  use LumberWeb, :controller

  alias Lumber.Wwsac

  def index(conn, _) do
    case Wwsac.get_next_wwsac_contest() do
      {:ok, contest} ->
        sub = Wwsac.build_wwsac_submission(contest)

        conn
        |> assign(:contest, contest)
        |> assign(
          :changeset,
          Wwsac.new_wwsac_submission_changeset(sub)
        )
        |> render()

      :error ->
        conn
        |> assign(:contest, nil)
        |> assign(:changeset, nil)
        |> render()
    end
  end
end
