defmodule MetricWeb.MeasurementController do
  use MetricWeb, :controller
  alias Metric.Measurements

  def create(conn, params) do
    current_user = conn.assigns[:current_user]

    case Measurements.insert_measurement(current_user, params) do
      {:ok, _} ->
        json(conn, %{"status" => "ok"})

      {:error, :type_not_allowed} ->
        json(conn, %{"status" => "error", "reason" => "Type not allowed"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(MetricWeb.ErrorView)
        |> render("validation_errors.json", changeset: changeset)
    end
  end
end
