defmodule Open2log.Repo do
  use Ecto.Repo,
    otp_app: :open2log,
    adapter: Ecto.Adapters.DuckDB
end
