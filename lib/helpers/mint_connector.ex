defmodule Helper.Mint.Connector do
  @moduledoc """
  Connector is ther connection owner process
  - Can request many resources on the same connector by req/5!

  - https://hexdocs.pm/mint/architecture.html#wrapping-a-mint-connection-in-a-genserver
  """

  use GenServer

  require Logger

  defstruct [:conn, requests: %{}]

  def start_link({scheme, host, port, opts}) do
    GenServer.start_link(__MODULE__, {scheme, host, port, opts})
  end

  def start({scheme, host, port, opts}) do
    GenServer.start(__MODULE__, {scheme, host, port, opts})
  end

  def req(pid, method, path, headers, body) do
    GenServer.call(pid, {:request, method, path, headers, body})
  end

  ## Callbacks

  @impl true
  def init({scheme, host, port, opts}) do
    case Mint.HTTP.connect(scheme, host, port, opts) do
      {:ok, conn} ->
        state = %__MODULE__{conn: conn}
        {:ok, state}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_call({:request, method, path, headers, body}, from, state) do
    # In both the successful case and the error case, we make sure to update the connection
    # struct in the state since the connection is an immutable data structure.
    case Mint.HTTP.request(state.conn, method, path, headers, body) do
      {:ok, conn, request_ref} ->
        state = put_in(state.conn, conn)
        # We store the caller this request belongs to and an empty map as the response.
        # The map will be filled with status code, headers, and so on.
        state = put_in(state.requests[request_ref], %{from: from, response: %{}})
        {:noreply, state}

      {:error, conn, reason} ->
        state = put_in(state.conn, conn)
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_info({:tcp, _port, _frame} = message, state) do
    message |> dbg
    # We should handle the error case here as well, but we're omitting it for brevity.
    case Mint.HTTP.stream(state.conn, message) do
      :unknown ->
        _ = Logger.error(fn -> "Received unknown message: " <> inspect(message) end)
        {:noreply, state}

      {:ok, conn, responses} ->
        state = put_in(state.conn, conn)

        state =
          Enum.reduce(responses, state, fn resp, st ->
            Logger.debug("got response frame #{resp |> inspect}")
            process_response(resp, st)
          end)

        {:noreply, state}

      {:error, conn, reason, [responses]} ->
        # todo
        Logger.error("#{reason |> inspect}")
        state = put_in(state.conn, conn)

        state =
          Enum.reduce(responses, state, fn resp, st ->
            Logger.debug("got response frame #{resp |> inspect}")
            process_response(resp, st)
          end)

        {:reply, reason, state}
    end
  end

  def handle_info({:tcp_closed, _port}, state) do
    IO.puts("#{self() |> inspect} tcp_closed")
    {:stop, :normal, state}
  end

  def handle_info(message, state) do
    {:other_ignore_msg, message} |> dbg
    {:noreply, state}
  end

  defp process_response({:status, request_ref, status}, state) do
    put_in(state.requests[request_ref].response[:status], status)
  end

  defp process_response({:headers, request_ref, headers}, state) do
    put_in(state.requests[request_ref].response[:headers], headers)
  end

  defp process_response({:data, request_ref, new_data}, state) do
    update_in(state.requests[request_ref].response[:data], fn data -> (data || "") <> new_data end)
  end

  # When the request is done, we use GenServer.reply/2 to reply to the caller that was
  # blocked waiting on this request.
  defp process_response({:done, request_ref}, state) do
    {%{response: response, from: from}, state} = pop_in(state.requests[request_ref])
    GenServer.reply(from, {:ok, response})
    state
  end

  # A request can also error, but we're not handling the erroneous responses for
  # brevity.
  defp process_response({:error, request_ref, reason}, state) do
    {%{response: response, from: from}, state} = pop_in(state.requests[request_ref])
    Logger.error({:error, reason, response, from} |> inspect)
    # todo check this
    GenServer.reply(from, {:error, reason})
    state
  end

  # http2 specific
  defp process_response({:pong, _request_ref}, state) do
    Logger.info("pong recevied!")
    state
  end

  # {:push_promise, request_ref, promised_request_ref, headers}
end
