defmodule Metric.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change() do
    create table(:users) do
      add :username, :string, null: false, default: ""
      add :firstname, :string, null: false, default: ""
      add :lastname, :string, null: false, default: ""
      add :surname, :string, null: false, default: ""
      add :height, :float, null: false, default: 0.0
      add :weight, :float, null: false, default: 0.0
      add :gender, :integer, null: false, default: 1
      add :hashed_password, :string, null: false, default: ""
      add :token, :string, null: false, default: ""
    end

    create unique_index(:users, [:username])
  end
end
