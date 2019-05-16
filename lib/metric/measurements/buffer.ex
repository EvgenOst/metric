defmodule Metric.Measurements.Buffer do
  use GenServer
  alias Metric.Repo
  alias Metric.Measurements.{Pulse, Pressure, Temperature}
  require Logger

  @measurements_buffer_config Application.fetch_env!(:metric, :measurements_buffer)
  @pool_size Keyword.fetch!(@measurements_buffer_config, :pool_size)
  @period_ms Keyword.fetch!(@measurements_buffer_config, :period_ms)
  @batch_size Keyword.fetch!(@measurements_buffer_config, :batch_size)
  @allowed_measurements [:pulse, :pressure, :temperature]

  ### API
  def start_link(index) do
    buffer_name = :"measurements_buffer_#{index}"
    state = {buffer_name, %{pulse: [], pressure: [], temperature: []}}
    GenServer.start_link(__MODULE__, state, name: buffer_name)
  end

  def push(measurement, params) when measurement in @allowed_measurements do
    worker_pid = random_worker()
    GenServer.cast(worker_pid, {:push, {measurement, params}})
  end
  def pust(_, _), do: :ok


  ### Callbacks
  def init({buffer_name, _} = state) do
    Logger.info("Start measurements buffer #{inspect(buffer_name)}")
    schedule_job()
    {:ok, state}
  end

  def handle_cast({:push, {measurement, params}}, {buffer_name, queue}) do
    updated_queue = queue[measurement] ++ [params]
    new_state = {buffer_name, Map.put(queue, measurement, updated_queue)}
    Logger.debug("Push #{inspect(measurement)} measurement to #{buffer_name}, params: #{inspect(params)}")

    {:noreply, new_state}
  end

  def handle_info(:insert, {buffer_name, queue}) do
    for measurement <- @allowed_measurements do
      schema = schema_by_measurement(measurement)
      params = Enum.take(queue[measurement], @batch_size)
      Repo.insert_all(schema, params)
    end

    updated_queue =
      Enum.map(queue, fn {k, v} ->
        with_removed_elems =
          v
          |> Enum.with_index(1)
          |> Enum.drop_while(fn {_e, i} -> i <= @batch_size end)
          |> Enum.map(fn {e, _i} -> e end)

        {k, with_removed_elems}
      end)
      |> Enum.into(%{})

    schedule_job()
    {:noreply, {buffer_name, updated_queue}}
  end


  ### Private
  defp random_worker() do
    index = Enum.random(1..@pool_size)
    Process.whereis(:"measurements_buffer_#{index}")
  end

  defp schema_by_measurement(:pulse), do: Pulse
  defp schema_by_measurement(:pressure), do: Pressure
  defp schema_by_measurement(:temperature), do: Temperature

  defp schedule_job(), do: self() |> Process.send_after(:insert, @period_ms)
end
