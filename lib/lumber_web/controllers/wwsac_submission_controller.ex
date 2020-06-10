defmodule LumberWeb.WwsacSubmissionController do
  use LumberWeb, :controller

  alias Lumber.Wwsac

  def create(conn, %{"submission" => %{"file" => file} = sub_params} = params) do
    contest =
      if sub_params["contest_id"] && LumberWeb.Authentication.role(conn) == :admin do
        Wwsac.get_contest(sub_params["contest_id"])
      else
        Wwsac.get_current_contest()
      end

    case contest do
      nil ->
        redirect(conn, to: Routes.page_path(conn, :index))

      contest ->
        Wwsac.build_wwsac_submission(contest)
        |> Wwsac.new_wwsac_submission_changeset(file.path)
        |> Wwsac.analyze_wwsac_submission_file_changeset()
        |> Wwsac.save_wwsac_submission()
        |> case do
          {:ok, sub} ->
            redirect_opts = if params["redirect"], do: [redirect: params["redirect"]], else: []

            redirect(conn,
              to: Routes.wwsac_submission_path(conn, :show, sub.id, redirect_opts)
            )

          {:error, changeset} ->
            conn
            |> assign(:changeset, changeset)
            |> assign(:page_title, "Log Submission")
            |> render(:index)
        end
    end
  end

  def create(conn, _) do
    redirect(conn, to: Routes.page_path(conn, :index))
  end

  def show(conn, %{"id" => id} = params) do
    case Wwsac.get_wwsac_submission(id) do
      {:ok, sub} ->
        options = %{
          age_group: Wwsac.age_group_options(),
          power_level: Wwsac.power_level_options()
        }

        conn
        |> assign(:sub, sub)
        |> assign(:page_title, "Log Submission")
        |> assign(:options, options)
        |> assign(:redirect, params["redirect"])
        |> assign(:changeset, Wwsac.prepare_wwsac_submission_changeset(sub))
        |> render()

      :error ->
        redirect(conn, to: Routes.page_path(conn, :index))
    end
  end

  def update(conn, %{"id" => id, "cancel" => "true"}) do
    with {:ok, sub} <- Wwsac.get_wwsac_submission(id) do
      Wwsac.cancel_wwsac_submission(sub)
    end

    redirect(conn, to: Routes.page_path(conn, :index))
  end

  def update(conn, %{"id" => id, "submission" => sub_params} = params) do
    with {:ok, sub} <- Wwsac.get_wwsac_submission(id) do
      sub
      |> Wwsac.prepare_wwsac_submission_changeset(sub_params)
      |> Wwsac.submit_wwsac_submission()
      |> case do
        {:ok, sub} ->
          redirect =
            if to_string(params["redirect"]) == "",
              do: Routes.wwsac_submission_path(conn, :show, sub.id),
              else: params["redirect"]

          conn
          |> put_session(:my_callsign, sub.callsign)
          |> redirect(to: redirect)

        {:error, changeset} ->
          options = %{
            age_group: Wwsac.age_group_options(),
            power_level: Wwsac.power_level_options()
          }

          conn
          |> assign(:sub, sub)
          |> assign(:options, options)
          |> assign(:changeset, changeset)
          |> assign(:page_title, "Log Submission")
          |> assign(:redirect, params["redirect"])
          |> render(:show)
      end
    else
      :error ->
        redirect(conn, to: Routes.page_path(conn, :index))
    end
  end
end
