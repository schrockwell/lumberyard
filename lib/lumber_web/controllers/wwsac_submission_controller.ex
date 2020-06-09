defmodule LumberWeb.WwsacSubmissionController do
  use LumberWeb, :controller

  alias Lumber.Wwsac

  def index(conn, _params) do
    sub = Wwsac.build_wwsac_submission()

    conn
    |> assign(:contest, Wwsac.get_next_wwsac_contest())
    |> assign(
      :changeset,
      Wwsac.new_wwsac_submission_changeset(sub)
    )
    |> render()
  end

  def create(conn, %{"submission" => %{"file" => file}}) do
    Wwsac.build_wwsac_submission()
    |> Wwsac.new_wwsac_submission_changeset(file.path)
    |> Wwsac.analyze_wwsac_submission_file_changeset()
    |> Wwsac.save_wwsac_submission()
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
