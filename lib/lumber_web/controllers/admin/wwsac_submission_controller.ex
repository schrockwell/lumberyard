defmodule LumberWeb.Admin.WwsacSubmissionController do
  use LumberWeb, :controller

  alias Lumber.Wwsac
  alias Lumber.WwsacAdmin

  def edit(conn, %{"id" => id}) do
    sub = WwsacAdmin.get_submission(id)

    options = %{
      age_group: Wwsac.age_group_options(),
      power_level: Wwsac.power_level_options()
    }

    conn
    |> assign(:page_title, "Edit #{sub.callsign} Log")
    |> assign(:options, options)
    |> assign(:sub, sub)
    |> assign(:changeset, WwsacAdmin.change_submission(sub))
    |> render()
  end

  def update(conn, %{"id" => id, "submission" => params}) do
    sub = WwsacAdmin.get_submission(id)

    case WwsacAdmin.create_or_update_submission(sub, params) do
      {:ok, sub} ->
        redirect(conn, to: Routes.admin_wwsac_submission_path(conn, :show, sub.id))

      {:error, changeset} ->
        options = %{
          age_group: Wwsac.age_group_options(),
          power_level: Wwsac.power_level_options()
        }

        conn
        |> assign(:page_title, "Edit #{sub.callsign} Log")
        |> assign(:options, options)
        |> assign(:sub, sub)
        |> assign(:changeset, changeset)
        |> render(:edit)
    end
  end

  def show(conn, %{"id" => id}) do
    sub = WwsacAdmin.get_submission(id)

    conn
    |> assign(:page_title, "Edit #{sub.callsign} Log")
    |> assign(:sub, sub)
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
