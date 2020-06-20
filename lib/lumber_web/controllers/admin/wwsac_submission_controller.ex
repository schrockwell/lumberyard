defmodule LumberWeb.Admin.WwsacSubmissionController do
  use LumberWeb, :controller

  alias Lumber.Wwsac
  alias Lumber.WwsacAdmin

  def new(conn, %{"contest_id" => contest_id}) do
    sub = WwsacAdmin.new_submission(contest_id)

    conn
    |> assign(:page_title, "New Log")
    |> assign_form(sub)
    |> render()
  end

  def create(conn, %{"submission" => params}) do
    sub = WwsacAdmin.new_submission(params["contest_id"])

    case WwsacAdmin.create_or_update_submission(sub, params) do
      {:ok, sub} ->
        redirect(conn, to: Routes.admin_wwsac_contest_path(conn, :show, sub.contest_id))

      {:error, changeset} ->
        conn
        |> assign(:page_title, "New Log")
        |> assign_form(sub)
        |> assign(:changeset, changeset)
        |> render(:new)
    end
  end

  def edit(conn, %{"id" => id}) do
    sub = WwsacAdmin.get_submission(id)

    conn
    |> assign(:page_title, "Edit #{sub.callsign} Log")
    |> assign_form(sub)
    |> render()
  end

  defp assign_form(conn, sub) do
    options = %{
      age_group: Wwsac.age_group_options(),
      power_level: Wwsac.power_level_options()
    }

    conn
    |> assign(:options, options)
    |> assign(:changeset, WwsacAdmin.change_submission(sub))
    |> assign(:sub, sub)
  end

  def update(conn, %{"id" => id, "submission" => params}) do
    sub = WwsacAdmin.get_submission(id)

    case WwsacAdmin.create_or_update_submission(sub, params) do
      {:ok, sub} ->
        redirect(conn, to: Routes.admin_wwsac_submission_path(conn, :show, sub.id))

      {:error, changeset} ->
        conn
        |> assign(:page_title, "Edit #{sub.callsign} Log")
        |> assign_form(sub)
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
