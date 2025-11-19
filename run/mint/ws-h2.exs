#! mix run

# websocket with http2
# https://hexdocs.pm/mint_web_socket/Mint.WebSocket.html#module-http-2-support

{:ok, conn} = Mint.HTTP.connect(:http, "localhost", 4000, protocols: [:http2])

# :http2 = Mint.HTTP.protocol(conn)

{:ok, conn, ref} = Mint.WebSocket.upgrade(:ws, conn, "/ws/hello", [])
# bandit not support ws over http2 at 2025.11.5
# %Mint.WebSocketError{reason: :extended_connect_disabled}
# :enable_connect_protocol
# if Mint.HTTP2.get_server_setting(conn, :enable_connect_protocol) == true do
#   extensions = get_extensions(opts)
#   conn = put_private(conn, :extensions, extensions)
#   headers =
#     [
#       {":scheme", if(scheme == :ws, do: "http", else: "https")},
#       {":path", path},
#       {":protocol", "websocket"}
#       | headers
#     ] ++ Utils.headers(:http2, extensions)
#   Mint.HTTP2.request(conn, "CONNECT", path, headers, :stream)
# else
#   {:error, conn, %WebSocketError{reason: :extended_connect_disabled}}
# end

# http_reply_message = receive(do: (message -> message))
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
