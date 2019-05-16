defmodule Metric.Repo.Migrations.CreatePressure do
  use Ecto.Migration

  def change() do
    create table(:pressure) do
      add :value, :map, null: false, default: %{"systolic" => 0, "diastolic" => 0}
      add :inserted_at, :naive_datetime, null: false
      add :user_id, references("users", on_delete: :delete_all), null: false
    end
  end
end
