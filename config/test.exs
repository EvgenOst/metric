use Mix.Config

# Configure your database
config :metric, Metric.Repo,
  username: "postgres",
  password: "postgres",
  database: "metric_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :metric, MetricWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :metric, :measurements_buffer,
  pool_size: 1,
  period_ms: 2000,
  batch_size: 2
