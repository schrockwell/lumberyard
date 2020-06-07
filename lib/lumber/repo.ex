defmodule Lumber.Repo do
  use Ecto.Repo,
    otp_app: :lumber,
    adapter: Ecto.Adapters.Postgres
end
