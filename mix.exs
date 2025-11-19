defmodule Bander.MixProject do
  use Mix.Project

  def project do
    [
      app: :bander,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      archives: [
        # https://github.com/cao7113/ehelper?tab=readme-ov-file#install
        # https://hexdocs.pm/mix/Mix.Tasks.Archive.Check.html
        # mix archive.check called by mix deps.get automatically unless --no-archives-check given
        {:ehelper, "~> 0.1"}
      ],
      aliases: aliases(),
      # deps: deps()
      deps: deps_with_linking_path()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Bander.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:thousand_island, "~> 1.4", local_linking: true},
      {:bandit, "~> 1.8", local_linking: true},
      {:websock_adapter, "~> 0.5.8"},
      {:mint, "~> 1.7", local_linking: true},
      {:mint_web_socket, "~> 1.0", local_linking: true},
      {:req, "~> 0.5", local_linking: true},
      {:plug, "~> 1.18", local_linking: true},
      {:plug_crypto, "~> 2.1", local_linking: true},
      # Livebook tools, todo: use node connect instead
      {:kino, "~> 0.16.0", only: [:dev]},
      {:kino_vega_lite, "~> 0.1.11", only: [:dev]}
    ]
  end

  ## Support deps local-linking
  def raw_deps, do: deps()

  def deps_with_linking_path(deps \\ deps()) do
    # Mix.Local.append_archives()
    # paths = :code.get_path() |> Enum.sort(); paths|>dbg

    Mix.DepLink
    |> Code.ensure_loaded()
    |> case do
      {:module, _} ->
        deps
        |> Mix.DepLink.deps_with_local_linking()

      {:error, reason} ->
        if Mix.env() in [:dev, :test] do
          Mix.raise(
            "Not found Mix.DepLink because: #{reason |> inspect}, please run: mix archive.install hex ehelper first!"
          )
        else
          deps
        end
    end
  end

  defp aliases do
    [
      c: "compile"
    ]
  end

  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]
end
