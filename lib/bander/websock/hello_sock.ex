defmodule Bander.WebSock.Hello do
  @moduledoc """
  Hello websock
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
  def init(arg) do
    Logger.info("==websock init with self: #{self() |> inspect} state arg: #{arg |> inspect}")

    # TODO process register
    unless Process.whereis(:ws) do
      Process.register(self(), :ws)
    end

    {:ok, arg}
  end

  @impl true
  def handle_in({"ping", [opcode: :text]}, state) do
    {:push, {:text, "pong"}, state}
  end

  def handle_in({msg, _opts} = data, state) do
    Logger.info("==websock handle_in with data: #{data |> inspect}")

    reply =
      "server reply: #{msg |> String.trim()} web_sock pid: #{self() |> inspect} with state: #{state |> inspect}"

    {:push, {:text, reply}, state}
  end

  @impl true
  def handle_info(msg, state) do
    state |> dbg
    Logger.info("==websock handle_info with msg: #{msg |> inspect}")
    {:push, {:text, "from server msg: #{msg |> inspect}"}, state}
  end

  @impl true
  def handle_control({msg, opcode}, state) do
    Logger.info("==websock handle_control with {msg, opcode}: #{{msg, opcode} |> inspect}")
    {:ok, state}
  end

  @impl true
  def terminate(reason, _state) do
    send(self(), reason)
    Logger.info("==terminate with reason: #{reason |> inspect}")
    :ok
  end
end
