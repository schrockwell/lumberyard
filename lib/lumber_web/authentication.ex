defmodule LumberWeb.Authentication do
  import Plug.Conn

  def role(conn) do
    get_session(conn, :role) || :guest
  end

  def try_log_in(conn, credentials) do
    if Lumber.Admin.authenticated?(credentials) do
      put_session(conn, :role, :admin)
    else
      put_session(conn, :role, :guest)
    end
  end

  def log_out(conn) do
    put_session(conn, :role, :guest)
  end
end
