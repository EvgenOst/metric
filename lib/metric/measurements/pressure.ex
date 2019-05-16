defmodule Metric.Measurements.Pressure do
  use Ecto.Schema

  schema "pressure" do
    belongs_to :user, Metric.Accounts.User

    field :value, :map
    field :inserted_at, :naive_datetime
  end
end
