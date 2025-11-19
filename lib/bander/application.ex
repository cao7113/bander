defmodule Bander.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    kland_log_level = Application.get_env(:bander, :kland_log_level, nil)

    if kland_log_level do
      ThousandIsland.Logger.attach_logger(kland_log_level)
    end

    children = [
      # Starts a worker by calling: Bander.Worker.start_link(arg)
      # {Bander.Worker, arg}
      Socker,
      {Bandit, Bander.bandit_default_opts()}
    ]

    children = if System.get_env("BANDER_SERVER"), do: children, else: []

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bander.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
