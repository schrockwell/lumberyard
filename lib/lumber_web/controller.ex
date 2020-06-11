defmodule LumberWeb.Controller do
  def redirect_back(conn, opts \\ []) do
    fallback = opts[:fallback]
    unless fallback, do: raise("The :fallback option for redirect_back/2 must be specified")

    case Plug.Conn.get_req_header(conn, "referer") do
      [] -> Phoenix.Controller.redirect(conn, to: fallback)
      [referer | _] -> Phoenix.Controller.redirect(conn, external: referer)
    end
  end
end
