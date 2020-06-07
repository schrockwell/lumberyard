defmodule Lumberyard.Repo do
  use Ecto.Repo,
    otp_app: :lumberyard,
    adapter: Ecto.Adapters.Postgres
end
