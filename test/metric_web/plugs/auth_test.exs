defmodule MetricWeb.Plugs.AuthTest do
  use MetricWeb.ConnCase
  alias MetricWeb.Plugs.Auth
  import Metric.Factory
  import Phoenix.Controller, only: [json: 2]

  describe "authenticate/2" do
    test "with valid params" do
      user = insert(:user, token: "token1234")
      assert {:ok, "token1234"} = Auth.authenticate(user.username, user.password)
    end

    test "with invalid params" do
      assert {:error, :invalid_params} = Auth.authenticate("user", "fake")
    end
  end

  describe "call/2" do
    test "with valid token" do
      user = insert(:user, token: "token888")
      conn = build_conn()
      conn = get(conn, "/api/v1/universal", %{"token" => user.token}) |> Auth.call() |> json(%{"status" => "ok"})
      assert json_response(conn, 200) == %{"status" => "ok"}
      assert conn.assigns[:current_user].id == user.id
    end

    test "with invalid params" do
      conn = build_conn()
      conn = get(conn, "/api/v1/universal") |> Auth.call()
      assert json_response(conn, 200) == %{"status" => "error", "reason" => "Unauthenticated"}
      assert conn.halted
    end
  end
end
