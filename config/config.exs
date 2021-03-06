# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :metric,
  ecto_repos: [Metric.Repo]

# Configures the endpoint
config :metric, MetricWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "3BGUUvwQAFnwPc9CtTXbsz/XzLjFb5k3mhoouwc+a/Id2WKqjl8cx7Vx0A04Ve9K",
  render_errors: [view: MetricWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Metric.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :metric, :measurements_buffer,
  pool_size: 5,
  period_ms: 200,
  batch_size: 100

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
