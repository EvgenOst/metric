defmodule Metric.Factory do
  use ExMachina.Ecto, repo: Metric.Repo

  def user_factory() do
    %Metric.Accounts.User{
      username: sequence(:username, &"user-#{&1}"),
      firstname: "Bruce",
      lastname: "Wayne",
      surname: "Batman",
      gender: Metric.Accounts.User.gender(:male),
      height: 175.0,
      weight: 77.0,
      password: "password",
      hashed_password: Bcrypt.Base.hash_password("password", Bcrypt.gen_salt(12, true))
    }
  end
end
