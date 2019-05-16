defmodule Metric.Measurements.ValidatorTest do
  use Metric.DataCase
  alias Metric.Measurements.Validator
  alias Metric.Measurements.{Pulse, Pressure, Temperature}
  import Metric.Factory

  describe "create_changeset/2" do
    setup do
      {:ok, user: insert(:user)}
    end

    test "when all params are valid", %{user: user} do
      schemas_and_values = [
        {%Pulse{}, 120},
        {%Pressure{}, %{"systolic" => 120, "diastolic" => 80}},
        {%Temperature{}, 36.6}
      ]

      for {schema, value} <- schemas_and_values do
        params = %{value: value, inserted_at: NaiveDateTime.utc_now(), user_id: user.id}
        changeset = Validator.create_changeset(schema, params)
        assert changeset.valid?
      end
    end

    test "validate value for pulse" do
      changeset = Validator.create_changeset(%Pulse{}, %{value: 0})
      assert "must be greater than 0" in errors_on(changeset)[:value]

      changeset = Validator.create_changeset(%Pulse{}, %{value: 300})
      assert "must be less than 300" in errors_on(changeset)[:value]
    end

    test "validate value for pressure" do
      for value <- [%{}, %{"systolic" => 0, "diastolic" => 0}, %{"systolic" => 400, "diastolic" => 400}] do
        changeset = Validator.create_changeset(%Pressure{}, %{value: value})
        assert "invalid pressure value" in errors_on(changeset)[:value]
      end
    end

    test "validate value for temperature" do
      changeset = Validator.create_changeset(%Temperature{}, %{value: 0})
      assert "must be greater than 0" in errors_on(changeset)[:value]

      changeset = Validator.create_changeset(%Temperature{}, %{value: 50})
      assert "must be less than 50" in errors_on(changeset)[:value]
    end
  end
end
