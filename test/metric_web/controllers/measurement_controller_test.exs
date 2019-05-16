defmodule Metric.MeasurementControllerTest do
  use MetricWeb.ConnCase
  alias Metric.Measurements.Buffer
  import Metric.Factory

  describe "POST /api/1/measurements" do
    setup do
      {:ok, _pid} = Buffer.start_link(1)
      {:ok, user: insert(:user)}
    end

    test "with valid params", %{user: user} do
      conn = build_conn()
      path = Routes.measurement_path(conn, :create)
      conn = post(conn, path, %{"token" => user.token, "type" => "pulse", "value" => 111})
      assert json_response(conn, 200) == %{"status" => "ok"}
    end

    test "with invalid params", %{user: user} do
      conn = build_conn()
      path = Routes.measurement_path(conn, :create)
      conn = post(conn, path, %{"token" => user.token, "type" => "pulse"})
      assert %{"status" => "error", "reason" => reason} = json_response(conn, 200)
      assert is_map(reason)
    end

    test "with unauthenticated user" do
      conn = build_conn()
      path = Routes.measurement_path(conn, :create)
      conn = post(conn, path, %{"token" => "fake", "type" => "pulse", "value" => 111})
      assert json_response(conn, 200) == %{"status" => "error", "reason" => "Unauthenticated"}
    end
  end
end
