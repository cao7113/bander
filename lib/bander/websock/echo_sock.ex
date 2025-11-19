defmodule Bander.WebSock.Echo do
  @moduledoc """
  Implement echo web-sock service:

  ## Links
  - https://hexdocs.pm/mint_web_socket/Mint.WebSocket.html#module-usage
  """

  @behaviour WebSock

  require Logger

  def state_of(pid) do
    {thousand_island_socket, handler_genserver_state} = :sys.get_state(pid)

    %{
      thousand_island_socket: thousand_island_socket,
      handler_genserver_state: handler_genserver_state
    }
  end

  @impl true
  def init(args \\ []) do
    Logger.info("==websock init self: #{self() |> inspect} with args: #{args |> inspect}")

    # # TODO process register
    # unless Process.whereis(:ws) do
    #   Process.register(self(), :ws)
    # end

    {:ok, args}
  end

  @impl true
  def handle_in({"server-state", [opcode: :text]}, state) do
    {:push, {:text, %{state: state, pid: self()} |> inspect}, state}
  end

  def handle_in({msg, [opcode: :text]}, state) when is_binary(msg) do
    {:push, {:text, msg}, state}
  end

  def handle_in({data, [opcode: :binary]}, state) when is_binary(data) do
    {:push, {:binary, data}, state}
  end

  def handle_in({msg, _opts} = data, state) do
    Logger.info("handle_in with data: #{data |> inspect}")
    reply = "reply: #{msg |> String.trim()}"
    {:push, {:text, reply}, state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.info("handle_info with msg: #{msg |> inspect}")
    {:push, {:text, "server msg: #{msg |> inspect}"}, state}
  end

  @impl true
  def handle_control({msg, opcode}, state) do
    Logger.info("handle_control with {msg, opcode}: #{{msg, opcode} |> inspect}")
    {:ok, state}
  end

  @impl true
  def terminate(reason, _state) do
    # send(self(), reason)
    Logger.info("terminate with reason: #{reason |> inspect}")
    :ok
  end
end
