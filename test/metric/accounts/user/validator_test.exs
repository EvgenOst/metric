defmodule Metric.Accounts.User.ValidatorTest do
  use Metric.DataCase
  alias Metric.{Utils, Repo}
  alias Metric.Accounts.User
  alias Metric.Accounts.User.Validator
  import Metric.Factory

  describe "create_changeset/2" do
    test "whan all params are valid" do
      params = params_for(:user)
      changeset = Validator.create_changeset(%User{}, params)
      assert changeset.valid?
    end

    test "validate username length" do
      params = %{username: Utils.random_string(51)}
      changeset = Validator.create_changeset(%User{}, params)
      assert "should be at most 50 character(s)" in errors_on(changeset)[:username]

      params = %{username: "a"}
      changeset = Validator.create_changeset(%User{}, params)
      assert "should be at least 2 character(s)" in errors_on(changeset)[:username]
    end

    test "validate username format" do
      for username <- ["with spaces", "with#", "нарусском"] do
        changeset = Validator.create_changeset(%User{}, %{username: username})
        assert "has invalid format" in errors_on(changeset)[:username]
      end

      for username <- ~w(one two2 three-3 four_4) do
        changeset = Validator.create_changeset(%User{}, %{username: username})
        assert errors_on(changeset)[:username] |> is_nil()
      end
    end

    test "validate username uniqueness" do
      user = insert(:user)
      params = params_for(:user, username: user.username)
      assert {:error, changeset} = Validator.create_changeset(%User{}, params) |> Repo.insert()
      assert "has already been taken" in errors_on(changeset)[:username] 
    end

    test "validate firstname length" do
      params = %{firstname: Utils.random_string(51)}
      changeset = Validator.create_changeset(%User{}, params)
      assert "should be at most 50 character(s)" in errors_on(changeset)[:firstname]

      params = %{firstname: "a"}
      changeset = Validator.create_changeset(%User{}, params)
      assert "should be at least 2 character(s)" in errors_on(changeset)[:firstname]
    end

    test "validate lastname length" do
      params = %{lastname: Utils.random_string(51)}
      changeset = Validator.create_changeset(%User{}, params)
      assert "should be at most 50 character(s)" in errors_on(changeset)[:lastname]

      params = %{lastname: "a"}
      changeset = Validator.create_changeset(%User{}, params)
      assert "should be at least 2 character(s)" in errors_on(changeset)[:lastname]
    end

    test "validate surname length" do
      params = %{surname: Utils.random_string(51)}
      changeset = Validator.create_changeset(%User{}, params)
      assert "should be at most 50 character(s)" in errors_on(changeset)[:surname]

      params = %{surname: "a"}
      changeset = Validator.create_changeset(%User{}, params)
      assert "should be at least 2 character(s)" in errors_on(changeset)[:surname]
    end

    test "validate height" do
      changeset = Validator.create_changeset(%User{}, %{height: 0.0})
      assert "must be greater than 0" in errors_on(changeset)[:height]

      changeset = Validator.create_changeset(%User{}, %{height: 301.0})
      assert "must be less than 301" in errors_on(changeset)[:height]
    end

    test "validate weight" do
      changeset = Validator.create_changeset(%User{}, %{weight: 0.0})
      assert "must be greater than 0" in errors_on(changeset)[:weight]

      changeset = Validator.create_changeset(%User{}, %{weight: 1000.0})
      assert "must be less than 1000" in errors_on(changeset)[:weight]
    end

    test "validate password length" do
      params = %{password: Utils.random_string(51)}
      changeset = Validator.create_changeset(%User{}, params)
      assert "should be at most 50 character(s)" in errors_on(changeset)[:password]

      changeset = Validator.create_changeset(%User{}, %{password: "123"})
      assert "should be at least 6 character(s)" in errors_on(changeset)[:password]
    end

    test "validate password format" do
      for password <- ["with space", "русскийпароль", "password_with_this"] do
        changeset = Validator.create_changeset(%User{}, %{password: password})
        assert "has invalid format" in errors_on(changeset)[:password]
      end
    end

    test "put hashed password" do
      params = params_for(:user, password: "somesecurepwd123", hashed_password: nil)
      changeset = Validator.create_changeset(%User{}, params)
      hashed_password = changeset.changes[:hashed_password]
      assert is_binary(hashed_password)
      assert Bcrypt.verify_pass("somesecurepwd123", hashed_password) == true
    end

    test "put token" do
      params = params_for(:user, token: nil)
      changeset = Validator.create_changeset(%User{}, params)
      assert is_binary(changeset.changes[:token])
    end

    test "validate gender inclusion" do
      changes = Validator.create_changeset(%User{}, %{gender: 100})
      assert "is invalid" in errors_on(changes)[:gender]
    end
  end
end
