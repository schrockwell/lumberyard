# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :lumber,
  ecto_repos: [Lumber.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :lumber, LumberWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TjKwAVvz0SGLcsLnoFmHjp+UAJ5jKWfwcaSf443u3AIK+l0gAJtv3Zmn7NC1ToCW",
  render_errors: [
    formats: [html: LumberWeb.ErrorHTML, json: LumberWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Lumber.PubSub,
  live_view: [signing_salt: "WO+qfrxq"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  lumber: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  lumber: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
