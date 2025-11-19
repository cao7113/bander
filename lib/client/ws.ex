defmodule Ws do
  @moduledoc """
  Play websocket
  """

  @port 4000

  def get_client() do
    client = SimpleWebSocketClient.tcp_client(port: @port)
    # headers = SimpleWebSocketClient.http1_handshake(client, :nothing, timeout: "250")
    client
  end

  def recv(client) do
    SimpleWebSocketClient.recv_text_frame(client)
  end

  def send(client, msg \\ "test from ws client") do
    SimpleWebSocketClient.send_text_frame(client, msg)
  end
end
