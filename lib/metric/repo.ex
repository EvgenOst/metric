defmodule Metric.Repo do
  use Ecto.Repo,
    otp_app: :metric,
    adapter: Ecto.Adapters.Postgres
end
