defmodule LumberWeb.Plugs do
  import Plug.Conn

  def put_my_callsign(conn, _) do
    assign(conn, :my_callsign, get_session(conn, :my_callsign))
  end

  def ensure_admin_role(conn, _) do
    if LumberWeb.Authentication.role(conn) == :admin do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(
        to: LumberWeb.Router.Helpers.login_path(conn, :show, redirect: conn.request_path)
      )
      |> halt()
    end
  end
end
