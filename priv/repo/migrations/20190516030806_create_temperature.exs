defmodule Metric.Repo.Migrations.CreateTemperature do
  use Ecto.Migration

  def change() do
    create table(:temperature) do
      add :value, :float, null: false, default: 0.0
      add :inserted_at, :naive_datetime, null: false
      add :user_id, references("users", on_delete: :delete_all), null: false
    end
  end
end
