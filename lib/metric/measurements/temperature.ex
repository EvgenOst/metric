defmodule Metric.Measurements.Temperature do
  use Ecto.Schema

  schema "temperature" do
    belongs_to :user, Metric.Accounts.User

    field :value, :float
    field :inserted_at, :naive_datetime
  end
end
