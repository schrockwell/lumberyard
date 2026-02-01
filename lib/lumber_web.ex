defmodule LumberWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels and so on.

  This can be used in your application as:

      use LumberWeb, :controller
      use LumberWeb, :html

  The definitions below will be executed for every component,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt apple-touch-icon.png favicon-16x16.png favicon-32x32.png site.webmanifest)

  def router do
    quote do
      use Phoenix.Router, helpers: true

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: LumberWeb.Layouts]

      import Plug.Conn
      import LumberWeb.Controller

      use Gettext, backend: LumberWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {LumberWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      import Phoenix.HTML
      import Phoenix.HTML.Form
      use PhoenixHTMLHelpers

      import LumberWeb.CoreComponents
      import Lumber.Format

      use Gettext, backend: LumberWeb.Gettext

      alias Phoenix.LiveView.JS

      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: LumberWeb.Endpoint,
        router: LumberWeb.Router,
        statics: LumberWeb.static_paths()

      # Keep legacy Routes alias for backward compatibility during migration
      alias LumberWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
