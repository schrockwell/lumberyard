defmodule LumberWeb.Admin.WwsacSubmissionController do
  use LumberWeb, :controller

  alias Lumber.WwsacAdmin

  def show(conn, %{"id" => id}) do
    conn
    |> assign(:sub, WwsacAdmin.get_submission(id))
    |> render()
  end

  def reject(conn, %{"id" => id}) do
    WwsacAdmin.reject_submission(id)

    redirect(conn, to: Routes.admin_wwsac_submission_path(conn, :show, id))
  end

  def unreject(conn, %{"id" => id}) do
    WwsacAdmin.unreject_submission(id)

    redirect(conn, to: Routes.admin_wwsac_submission_path(conn, :show, id))
  end
end
