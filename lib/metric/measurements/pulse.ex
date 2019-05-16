defmodule Metric.Measurements.Pulse do
  use Ecto.Schema

  schema "pulse" do
    belongs_to :user, Metric.Accounts.User

    field :value, :integer
    field :inserted_at, :naive_datetime
  end
end
