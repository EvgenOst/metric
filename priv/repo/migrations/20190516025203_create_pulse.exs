defmodule Metric.Repo.Migrations.CreatePulse do
  use Ecto.Migration

  def change() do
    create table(:pulse) do
      add :value, :integer, null: false, default: 0
      add :inserted_at, :naive_datetime, null: false
      add :user_id, references("users", on_delete: :delete_all), null: false
    end
  end
end
