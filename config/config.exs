# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :lumber,
  ecto_repos: [Lumber.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :lumber, LumberWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TjKwAVvz0SGLcsLnoFmHjp+UAJ5jKWfwcaSf443u3AIK+l0gAJtv3Zmn7NC1ToCW",
  render_errors: [view: LumberWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Lumber.PubSub,
  live_view: [signing_salt: "WO+qfrxq"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
