defmodule MetricWeb.UserController do
  use MetricWeb, :controller
  alias Metric.Accounts
  alias MetricWeb.Plugs.Auth

  def create(conn, params) do
    case Accounts.create_user(params) do
      {:ok, user} ->
        json(conn, %{"status" => "ok", "token" => user.token})

      {:error, changeset} ->
        conn
        |> put_view(MetricWeb.ErrorView)
        |> render("validation_errors.json", changeset: changeset)
    end
  end

  def authenticate(conn, params) do
    case Auth.authenticate(params["username"], params["password"]) do
      {:ok, token} -> json(conn, %{"status" => "ok", "token" => token})
      _error -> json(conn, %{"status" => "error", "reason" => "Invalid username or password"})
    end
  end
end
