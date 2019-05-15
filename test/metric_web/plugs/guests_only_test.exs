defmodule MetricWeb.Plugs.GuestsOnlyTest do
  use MetricWeb.ConnCase
  alias MetricWeb.Plugs.GuestsOnly
  import Metric.Factory
  import Phoenix.Controller, only: [json: 2]

  describe "call/2" do
    test "when user isn't authenticated" do
      resp = %{"something" => "ok"}
      conn = build_conn() |> GuestsOnly.call([]) |> json(resp)
      assert json_response(conn, 200) == resp
    end

    test "when user is authenticated" do
      conn = insert(:user) |> auth_conn() |> GuestsOnly.call([])
      assert json_response(conn, 200) == %{"status" => "error", "reason" => "Already authenticated"}
      assert conn.halted
    end
  end
end
