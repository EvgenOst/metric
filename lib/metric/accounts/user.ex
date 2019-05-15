defmodule Metric.Accounts.User do
  use Ecto.Schema

  schema "users" do
    field :username, :string
    field :firstname, :string
    field :lastname, :string
    field :surname, :string
    field :height, :float
    field :weight, :float
    field :gender, :integer
    field :hashed_password, :string
    field :token, :string

    field :password, :string, virtual: true
  end

  @spec genders() :: map
  def genders(), do: %{male: 1, female: 2}

  @spec gender(atom) :: non_neg_integer | nil
  def gender(gender), do: genders()[gender]
end
