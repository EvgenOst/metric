defmodule Metric.Measurements do
  alias Metric.Accounts.User
  alias Metric.Measurements.Validator
  alias Metric.Measurements.{Buffer, Pulse, Pressure, Temperature}

  @allowed_types ~w(pulse pressure temperature)

  @spec insert_measurement(%User{}, map) :: {:ok, :pulse | :pressure | :temperature} | {:error, term}
  def insert_measurement(%User{} = user, %{"type" => type} = params) when type in @allowed_types do
    type = String.to_atom(type)
    schema = struct_by_type(type)
    datetime = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    params = %{user_id: user.id, inserted_at: datetime, value: params["value"]}
    changeset = Validator.create_changeset(schema, params)

    if changeset.valid? do
      params = Map.take(changeset.changes, [:value, :inserted_at, :user_id]) |> Enum.into([])
      Buffer.push(type, params)
      {:ok, type}
    else
      {:error, changeset}
    end
  end
  def insert_measurement(_, _), do: {:error, :type_not_allowed}

  defp struct_by_type(:pulse), do: %Pulse{}
  defp struct_by_type(:pressure), do: %Pressure{}
  defp struct_by_type(:temperature), do: %Temperature{}
end
