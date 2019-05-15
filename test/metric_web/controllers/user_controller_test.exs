defmodule MetricWeb.UserControllerTest do
  use MetricWeb.ConnCase
  alias Metric.Accounts
  import Metric.Factory

  describe "POST /api/v1/users" do
    test "with valid params" do
      conn = build_conn()
      params = params_for(:user)
      path = Routes.user_path(conn, :create)
      conn = post(conn, path, params)
      token = Accounts.get_by_username(params.username).token

      assert json_response(conn, 200) == %{"status" => "ok", "token" => token}
    end

    test "with invalid params" do
      conn = build_conn()
      path = Routes.user_path(conn, :create)
      conn = post(conn, path, %{})

      assert %{"status" => "error", "reason" => errors} = json_response(conn, 200)
      assert is_map(errors)
    end

    test "when user is authenticated" do
      conn = insert(:user) |> auth_conn()
      params = params_for(:user)
      path = Routes.user_path(conn, :create)
      conn = post(conn, path, params)

      assert json_response(conn, 200) == %{"status" => "error", "reason" => "Already authenticated"}
    end
  end

  describe "POST /api/v1/users/auth" do
    test "with valid params" do
      conn = build_conn()
      user = insert(:user, token: "token123")
      params = %{"username" => user.username, "password" => user.password}
      path = Routes.user_path(conn, :authenticate)
      conn = post(conn, path, params)

      assert json_response(conn, 200) == %{"status" => "ok", "token" => user.token}
    end

    test "with invalid params" do
      conn = build_conn()
      path = Routes.user_path(conn, :authenticate)
      conn = post(conn, path, %{})

      assert %{"status" => "error", "reason" => "Invalid username or password"} = json_response(conn, 200)
    end

    test "when user is authenticated" do
      user = insert(:user)
      conn = auth_conn(user)
      params = %{"username" => user.username, "password" => user.password}
      path = Routes.user_path(conn, :authenticate)
      conn = post(conn, path, params)

      assert json_response(conn, 200) == %{"status" => "error", "reason" => "Already authenticated"}
    end
  end
end
