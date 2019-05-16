defmodule Metric.Measurements.BufferTest do
  use Metric.DataCase
  alias Metric.Repo
  alias Metric.Measurements.Buffer
  alias Metric.Measurements.{Pulse, Pressure, Temperature}
  import Metric.Factory
  import Ecto.Query

  @measurements_buffer_config Application.fetch_env!(:metric, :measurements_buffer)
  @period_ms Keyword.fetch!(@measurements_buffer_config, :period_ms)
  @batch_size Keyword.fetch!(@measurements_buffer_config, :batch_size)

  setup do
    {:ok, pid} = Buffer.start_link(1)
    datetime = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    {:ok, pid: pid, user: insert(:user), datetime: datetime}
  end

  test "push elems and insert by N entries each M ms", %{pid: pid, user: user, datetime: datetime} do
    for _ <- 1..4, do: Buffer.push(:pulse, [value: 100, user_id: user.id, inserted_at: datetime])
    for _ <- 1..6, do: Buffer.push(:pressure, [value: %{"systolic" => 120, "diastolic" => 80}, user_id: user.id, inserted_at: datetime])
    for _ <- 1..8, do: Buffer.push(:temperature, [value: 36.6, user_id: user.id, inserted_at: datetime])

    {:measurements_buffer_1, %{pulse: pulse, pressure: pressure, temperature: temperature}} = :sys.get_state(pid)
    assert Enum.count(pulse) == 4
    assert Enum.count(pressure) == 6
    assert Enum.count(temperature) == 8

    :timer.sleep(@period_ms + 100)

    {:measurements_buffer_1, %{pulse: pulse2, pressure: pressure2, temperature: temperature2}} = :sys.get_state(pid)
    assert Enum.count(pulse2) == Enum.count(pulse) - @batch_size
    assert Enum.count(pressure2) == Enum.count(pressure) - @batch_size
    assert Enum.count(temperature2) == Enum.count(temperature) - @batch_size

    assert from(p in Pulse, select: count(p.id)) |> Repo.one!() == @batch_size
    assert from(p in Pressure, select: count(p.id)) |> Repo.one!() == @batch_size
    assert from(t in Temperature, select: count(t.id)) |> Repo.one!() == @batch_size
  end
end
