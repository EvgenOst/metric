defmodule MetricWeb.Plugs.GuestsOnly do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def init(opts), do: opts

  @spec call(Plug.Conn.t(), keyword) :: Plug.Conn.t()
  def call(conn, _opts \\ []) do
    if conn.assigns[:current_user] do
      conn |> json(%{"status" => "error", "reason" => "Already authenticated"}) |> halt()
    else
      conn
    end
  end
end
