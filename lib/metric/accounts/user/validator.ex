defmodule Metric.Accounts.User.Validator do
  alias Metric.Accounts.User
  import Ecto.Changeset

  @create_required_fields [
    :username, :firstname, :lastname,
    :height, :weight, :gender,
    :password
  ]
  @create_optional_fields [:surname, :hashed_password, :token]

  @allowed_genders User.genders() |> Map.values()

  @spec create_changeset(%User{}, map) :: Ecto.Changeset.t()
  def create_changeset(%User{} = user, params \\ %{}) do
    user
    |> cast(params, @create_required_fields ++ @create_optional_fields)
    |> validate_required(@create_required_fields)
    |> validate_username()
    |> validate_firstname()
    |> validate_lastname()
    |> validate_surname()
    |> validate_height()
    |> validate_weight()
    |> validate_gender()
    |> validate_password()
    |> put_token()
    |> put_hashed_password()
  end

  defp validate_username(changeset) do
    changeset
    |> update_change(:username, &String.downcase/1)
    |> validate_format(:username, ~r/^[a-zA-Z0-9._-]*$/)
    |> validate_length(:username, min: 2, max: 50)
    |> unique_constraint(:username)
  end

  defp validate_firstname(changeset), do: validate_length(changeset, :firstname, min: 2, max: 50)

  defp validate_lastname(changeset), do: validate_length(changeset, :lastname, min: 2, max: 50)

  defp validate_surname(changeset), do: validate_length(changeset, :surname, min: 2, max: 50)

  defp validate_height(changeset), do: validate_number(changeset, :height, greater_than: 0, less_than: 301)

  defp validate_weight(changeset), do: validate_number(changeset, :weight, greater_than: 0, less_than: 1_000)

  defp validate_gender(changeset), do: validate_inclusion(changeset, :gender, @allowed_genders)

  defp validate_password(changeset) do
    changeset
    |> validate_length(:password, min: 6, max: 50)
    |> validate_format(:password, ~r/^[a-zA-Z0-9]*$/)
  end

  defp put_token(%Ecto.Changeset{valid?: true, changes: changes} = changeset) do
    salt = "vkASdnvskLmmZ8278ASdjlon"
    token = Phoenix.Token.sign(MetricWeb.Endpoint, salt, changes[:username])
    put_change(changeset, :token, token)
  end
  defp put_token(changeset), do: changeset

  defp put_hashed_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    salt = Bcrypt.gen_salt(12, true)
    hashed_password = Bcrypt.Base.hash_password(password, salt)
    put_change(changeset, :hashed_password, hashed_password)
  end
  defp put_hashed_password(changeset), do: changeset
end
