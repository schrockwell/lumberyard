defmodule LumberWeb.WwsacSubmissionController do
  use LumberWeb, :controller

  alias Lumber.Contests

  def index(conn, _params) do
    sub = Contests.build_wwsac_submission()

    conn
    |> assign(:contest, Contests.get_next_wwsac_contest())
    |> assign(
      :changeset,
      Contests.new_wwsac_submission_changeset(sub)
    )
    |> render()
  end

  def create(conn, %{"wwsac_submission" => %{"file" => file}}) do
    Contests.build_wwsac_submission()
    |> Contests.new_wwsac_submission_changeset(file.path)
    |> Contests.save_wwsac_submission()
    |> case do
      {:ok, sub} ->
        redirect(conn, to: Routes.prepare_wwsac_submission_path(conn, :index, sub.id))

      {:error, changeset} ->
        conn
        |> assign(:changeset, changeset)
        |> render(:index)
    end
  end
end
