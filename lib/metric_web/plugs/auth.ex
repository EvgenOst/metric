defmodule MetricWeb.Plugs.Auth do
  alias Metric.Accounts
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def init(opts), do: opts

  @spec call(Plug.Conn.t(), keyword) :: Plug.Conn.t()
  def call(conn, _opts \\ []) do
    token = conn.params["token"] || ""
    user = Accounts.get_by_token(token)

    if user do
      assign(conn, :current_user, user)
    else
      conn
      |> json(%{"status" => "error", "reason" => "Unathenticated"})
      |> halt()
    end
  end

  def authenticate(username, password) do
    username = username || ""
    password = password || ""

    user = Accounts.get_by_username(username)

    if user && valid_password?(user, password) do
      {:ok, user.token}
    else
      {:error, :invalid_params}
    end
  end

  defp valid_password?(user, password) do
    Bcrypt.verify_pass(password, user.hashed_password)
  end
end
