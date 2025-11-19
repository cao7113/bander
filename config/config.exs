import Config

# custom app status error to plug status codes
# iex>  Plug.Conn.Status.reason_phrase 1000
config :plug, :statuses, %{
  1000 => "App test error"
}

# :error | :info | :debug | :trace
config :bander, :kland_log_level, :error
config :bander, :kland_opts, port: 0

case config_env() do
  :dev ->
    # config :bander, :kland_log_level, :trace

    config :bander, :kland_opts,
      handler_module: Socker.EchoHandler,
      # handler_module: Socker.HTTPHandler,
      transport_module: ThousandIsland.Transports.TCP,
      transport_options: [
        # certfile: Path.join(__DIR__, "../keys/test/server.crt"),
        # keyfile: Path.join(__DIR__, "../keys/test/dev.key"),
        send_timeout: 300_000
      ]

  _ ->
    nil
end
