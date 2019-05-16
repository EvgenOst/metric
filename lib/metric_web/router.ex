defmodule MetricWeb.Router do
  use MetricWeb, :router
  alias MetricWeb.Plugs.{Auth, GuestsOnly}

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Only for not authenticated users
  scope "/api/v1", MetricWeb do
    pipe_through [:api, GuestsOnly]

    post "/users", UserController, :create
    post "/users/auth", UserController, :authenticate
  end

  # With authentication
  scope "/api/v1", MetricWeb do
    pipe_through [:api, Auth]

    post "/measurements", MeasurementController, :create
  end

  scope "/api/v1", MetricWeb do
    pipe_through :api

    get "/universal", UniversalController, :universal
  end
end
