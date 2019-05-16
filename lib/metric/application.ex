defmodule Metric.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @measurements_buffer_config Application.fetch_env!(:metric, :measurements_buffer)

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Metric.Repo,
      # Start the endpoint when the application starts
      MetricWeb.Endpoint
      # Starts a worker by calling: Metric.Worker.start_link(arg)
      # {Metric.Worker, arg},
    ] ++ measurements_buffer_workers()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Metric.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MetricWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp measurements_buffer_workers() do
    pool_size = Keyword.fetch!(@measurements_buffer_config, :pool_size)

    for index <- 1..pool_size do
      Supervisor.child_spec({Metric.Measurements.Buffer, index}, id: :"measurements_buffer_#{index}")
    end
  end
end
