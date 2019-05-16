defmodule Metric.MeasurementsTest do
  use Metric.DataCase
  alias Metric.Measurements
  alias Metric.Measurements.Buffer
  import Metric.Factory

  describe "insert_measurement/2" do
    setup do
      {:ok, pid} = Buffer.start_link(1)
      {:ok, pid: pid, user: insert(:user)}
    end

    test "adds pulse measurement in buffer", %{pid: pid, user: user} do
      assert {:ok, :pulse} = Measurements.insert_measurement(user, %{"type" => "pulse", "value" => 120})
      assert {_, %{pulse: [measurement]}} = :sys.get_state(pid)
      assert measurement[:user_id] == user.id
      assert measurement[:value] == 120
      refute is_nil(measurement[:inserted_at])
    end

    test "adds pressure measurement in buffer", %{pid: pid, user: user} do
      value = %{"systolic" => 140, "diastolic" => 90}
      assert {:ok, :pressure} = Measurements.insert_measurement(user, %{"type" => "pressure", "value" => value})
      assert {_, %{pressure: [measurement]}} = :sys.get_state(pid)
      assert measurement[:user_id] == user.id
      assert measurement[:value] == value
      refute is_nil(measurement[:inserted_at])
    end

    test "adds temperature measurement in buffer", %{pid: pid, user: user} do
      assert {:ok, :temperature} = Measurements.insert_measurement(user, %{"type" => "temperature", "value" => 36.6})
      assert {_, %{temperature: [measurement]}} = :sys.get_state(pid)
      assert measurement[:user_id] == user.id
      assert measurement[:value] == 36.6
      refute is_nil(measurement[:inserted_at])
    end

    test "with unsupported type", %{pid: pid, user: user} do
      assert {:error, :type_not_allowed} = Measurements.insert_measurement(user, %{"type" => "fake"})
      assert {_, %{pulse: [], pressure: [], temperature: []}} = :sys.get_state(pid)
    end

    test "with invalid params", %{pid: pid, user: user} do
      assert {:error, %Ecto.Changeset{valid?: false}} = Measurements.insert_measurement(user, %{"type" => "pulse"})
      assert {_, %{pulse: [], pressure: [], temperature: []}} = :sys.get_state(pid)
    end
  end
end
