defmodule Metric.AccountsTest do
  use Metric.DataCase
  alias Metric.Accounts
  alias Metric.Accounts.User
  import Metric.Factory

  describe "create_user/1" do
    test "with valid params" do
      params = params_for(:user)
      assert {:ok, %User{} = user} = Accounts.create_user(params)

      for {k, v} <- Map.delete(params, :hashed_password) do
        assert Map.get(user, k) == v
      end
    end

    test "with invalid params" do
      assert {:error, %Ecto.Changeset{valid?: false}} = Accounts.create_user(%{})
    end
  end
end
