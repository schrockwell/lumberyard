defmodule LumberWeb.LoginController do
  use LumberWeb, :controller

  def show(conn, _) do
    conn
    |> render()
  end

  def create(conn, params) do
    conn = conn |> LumberWeb.Authentication.try_log_in(params)
    redirect_path = params["redirect"] || Routes.admin_wwsac_contest_path(conn, :index)

    case get_session(conn, :role) do
      :guest -> redirect(conn, to: Routes.login_path(conn, :show))
      :admin -> redirect(conn, to: redirect_path)
    end
  end

  def delete(conn, _) do
    conn
    |> LumberWeb.Authentication.log_out()
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
