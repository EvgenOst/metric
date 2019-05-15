defmodule Metric.Accounts do
  alias Metric.Repo
  alias Metric.Accounts.User
  alias Metric.Accounts.User.Validator

  @spec create_user(map) :: {:ok, %User{}} | {:error, Ecto.Changeset.t()}
  def create_user(params) do
    %User{} |> Validator.create_changeset(params) |> Repo.insert()
  end

  @spec get_by_username(String.t()) :: %User{} | nil
  def get_by_username(username), do: Repo.get_by(User, username: username)

  @spec get_by_token(String.t()) :: %User{} | nil
  def get_by_token(token), do: Repo.get_by(User, token: token)
end
