defmodule Helper.Mint do
  @moduledoc """
  Dig Mint
  """

  alias Helper.Mint.Connector

  @default_http1_opts [
    debug: true
  ]

  @default_http2_opts [
    debug: true,
    protocols: [:http2],
    client_settings: [
      enable_push: true
    ]
  ]

  def get_state(pid), do: :sys.get_state(pid)

  def start_connector(opts \\ @default_http1_opts) do
    {:ok, pid} =
      Connector.start({:http, "localhost", 4000, opts})

    pid
  end

  @doc """
  use http2 protocol to connect
  """
  def start_connector2, do: start_connector(@default_http2_opts)

  def req(connector_pid, info \\ []) do
    defaults = [method: "GET", path: "/", headers: [], body: nil]

    %{method: method, path: path, headers: headers, body: body} =
      defaults |> Keyword.merge(info) |> Map.new()

    Connector.req(connector_pid, method, path, headers, body)
  end

  ## http2 settings

  # server_settings: %{
  #   enable_push: true,
  #   max_concurrent_streams: 100,
  #   initial_window_size: @default_window_size,
  #   max_frame_size: @default_max_frame_size,
  #   max_header_list_size: :infinity,
  #   # Only supported by the server: https://www.rfc-editor.org/rfc/rfc8441.html#section-3
  #   enable_connect_protocol: false
  # },
  # # Settings that the client communicates to the server.
  # client_settings: %{
  #   max_concurrent_streams: 100,
  #   initial_window_size: @default_window_size,
  #   max_header_list_size: :infinity,
  #   max_frame_size: @default_max_frame_size,
  #   enable_push: true
  # },

  @setting_names [
    # :header_table_size,
    # :enable_connect_protocol,
    :enable_push,
    :max_concurrent_streams,
    :initial_window_size,
    :max_frame_size,
    :max_header_list_size
  ]
  def get_settings(conn) do
    cs =
      Enum.map(@setting_names, fn s ->
        {s, Mint.HTTP2.get_client_setting(conn, s)}
      end)

    ss =
      Enum.map(@setting_names, fn s ->
        {s, Mint.HTTP2.get_server_setting(conn, s)}
      end)

    %{client_settings: cs, server_settings: ss}
  end
end
