defmodule H2 do
  @port 4000
  # https://httpwg.org/specs/rfc7540.html#rfc.section.3.5
  @pre "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n"

  def get_client(opts \\ []) do
    port = Keyword.get(opts, :port, @port)
    connect_opts = Keyword.get(opts, :connect, [])
    {:ok, s} = :gen_tcp.connect(:localhost, port, connect_opts)
    :ok = :gen_tcp.send(s, @pre)
    s
  end
end
