defmodule Bander do
  @moduledoc """
  Documentation for `Bander`.
  """

  @app Application.get_application(__MODULE__)

  def app_sup, do: Process.whereis(Bander.Supervisor)
  def sup, do: app_sup()
  def app, do: @app

  def restart(app \\ @app) do
    Application.stop(app)
    Application.start(app)
  end

  @server_name Bander.Server

  # same as bandit_server_pid but by registry_name
  def bandit_server, do: Process.whereis(@server_name)

  def bandit_server_pid(sup \\ app_sup()) do
    Supervisor.which_children(sup)
    |> Enum.find_value(fn
      {{Bandit, _}, pid, :supervisor, [Bandit]} -> pid
      _ -> false
    end)
  end

  def bandit(), do: bandit_server_pid()
  def kland_server, do: bandit_server_pid()

  def bandit_default_opts do
    # https://hexdocs.pm/bandit/Bandit.html#t:options/0
    [
      # plug: Bander.Plug,
      # pass plug_opts when plug called
      # plug: {Bander.Plug, [test: :test123]},
      plug: Bander.Router,
      scheme: :http,
      port: 4000,
      # ip: :loopback,
      ip: :any,
      ## options to handler as state
      # handler_options: [],
      # https://hexdocs.pm/thousand_island/1.4.2/ThousandIsland.html#t:options/0
      thousand_island_options: [
        # num_acceptors: 100,
        num_acceptors: 2,
        # genserver_options: [debug: [:trace]],
        supervisor_options: [
          # ThousandIsland.Server as supervisor name
          name: @server_name
        ]
      ],
      startup_log: :debug
    ]
  end
end
