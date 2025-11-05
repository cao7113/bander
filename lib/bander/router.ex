defmodule Bander.Router do
  @moduledoc """
  Test router
  """

  use Plug.Router
  require Logger

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> send_resp(200, "Welcome!")
  end

  # connect info
  get "/info" do
    %{adapter: {_adapter, %{transport: transport} = adapter}} = conn
    http_version = Bandit.HTTPTransport.version(transport)

    # show stream id when http2 todo

    # conn_info =
    #   case Map.get(transport, :connection_pid) do
    #     pid when is_pid(pid) ->
    #       :sys.get_state(pid)

    #     _ ->
    #       :self
    #   end

    {:conn, http_version, self(), adapter} |> dbg

    info =
      %{
        http_version: http_version
      }
      |> JSON.encode!()

    conn
    |> send_resp(:ok, info)
  end

  get "/hello" do
    conn
    |> send_resp(200, "world")
  end

  get "/ws/jsclient" do
    conn
    # Provide the user with some useful instructions to copy & paste into their inspector
    |> send_resp(200, """
    ## Use the JavaScript console to interact using websockets

    sock  = new WebSocket("ws://localhost:4000/websocket")
    sock.addEventListener("message", console.log)
    sock.addEventListener("open", () => sock.send("ping"))
    """)
  end

  get "/websocket" do
    websock = Bander.WebSock
    websock_init_arg = []
    websocket_opts = [timeout: 60_000]
    Logger.info("plug-connection: #{self() |> inspect} before websocket upgrade handshake!")

    conn
    # |> put_resp_header("x-plug-set-header", "itsaheader")
    |> WebSockAdapter.upgrade(websock, websock_init_arg, websocket_opts)
    |> halt()
  end

  get "/joke" do
    Bander.JokePlug.call(conn, [])
  end

  get "/error" do
    # Quiet the compiler
    _ = conn
    apply(:erlang, :+, [1, self()])
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
