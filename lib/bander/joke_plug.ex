defmodule Bander.JokePlug do
  @moduledoc """
  app plug
  """

  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(opts) do
    opts
  end

  @impl Plug
  def call(conn, _opts) do
    raise Bander.JokeError, "Mock a teapot by runtime error"
    conn |> send_resp(:ok, "Hello bander!")
  end
end
