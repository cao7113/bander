#! mix run

# https://hexdocs.pm/mint_web_socket/Mint.WebSocket.html#module-usage

{:ok, conn} = Mint.HTTP.connect(:http, "localhost", 4000)
{:ok, conn, ref} = Mint.WebSocket.upgrade(:ws, conn, "/ws/hello", [])

http_reply_message =
  receive do
    msg -> msg
  end

{:tcp, _, handshake_resp} = http_reply_message
IO.puts(handshake_resp)

{:ok, conn, [{:status, ^ref, status}, {:headers, ^ref, resp_headers}, {:done, ^ref}]} =
  Mint.WebSocket.stream(conn, http_reply_message)

{:ok, conn, websocket} =
  Mint.WebSocket.new(conn, ref, status, resp_headers)

{:ok, websocket, data} = Mint.WebSocket.encode(websocket, {:text, "hello world"})
{:ok, conn} = Mint.WebSocket.stream_request_body(conn, ref, data)

echo_message =
  receive do
    msg -> msg
  end

{:ok, _conn, [{:data, ^ref, data}]} = Mint.WebSocket.stream(conn, echo_message)
{:ok, _websocket, [{:text, reply_msg}]} = Mint.WebSocket.decode(websocket, data)
reply_msg |> dbg

## Legacy

#  iex>  c = Wst.get_client()
#   >>  Wst.send(c, "test")

# @port 4000

# def get_client() do
#   client = SimpleWebSocketClient.tcp_client(port: @port)
#   headers = SimpleWebSocketClient.http1_handshake(client, :nothing, timeout: "250")
#   headers |> dbg

#   client
# end

# def recv(client) do
#   SimpleWebSocketClient.recv_text_frame(client)
# end

# def send(client, msg \\ "test from ws client") do
#   SimpleWebSocketClient.send_text_frame(client, msg)
# end
