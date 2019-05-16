defmodule Metric.Measurements.Validator do
  alias Metric.Measurements.{Pulse, Pressure, Temperature}
  import MetricWeb.Gettext, only: [dgettext: 2]
  import Ecto.Changeset

  @create_required_fields [:value, :inserted_at, :user_id]

  @spec create_changeset(%Pulse{} | %Pressure{} | %Temperature{}, map) :: Ecto.Changeset.t()
  def create_changeset(measurement, params \\ %{}) do
    measurement
    |> cast(params, @create_required_fields)
    |> validate_required(@create_required_fields)
    |> validate_value(measurement)
  end

  defp validate_value(changeset, %Pulse{}) do
    validate_number(changeset, :value, greater_than: 0, less_than: 300)
  end

  defp validate_value(changeset, %Pressure{}) do
    error = [value: dgettext("errors", "invalid pressure value")]

    validate_change(changeset, :value, fn :value, value ->
      case value do
        %{"systolic" => sys, "diastolic" => dia} -> validate_pressure(sys, dia, error)
        _other -> error
      end
    end)
  end

  defp validate_value(changeset, %Temperature{}) do
    validate_number(changeset, :value, greater_than: 0, less_than: 50)
  end

  defp validate_pressure(sys, dia, error) do
    if sys > 0 && dia > 0 && sys < 400 && dia < 400 do
      []
    else
      error
    end
  end
end
