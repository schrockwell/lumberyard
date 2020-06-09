defmodule LumberWeb.WwsacSubmissionController do
  use LumberWeb, :controller

  alias Lumber.Wwsac

  def index(conn, _params) do
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

  def create(conn, %{"submission" => %{"file" => file}}) do
    case Wwsac.get_next_wwsac_contest() do
      {:ok, contest} ->
        Wwsac.build_wwsac_submission(contest)
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

      :error ->
        redirect(conn, to: Routes.wwsac_submission_path(conn, :index))
    end
  end
end
