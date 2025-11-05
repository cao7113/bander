defmodule Bander.MixProject do
  use Mix.Project

  def project do
    [
      app: :bander,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:websock_adapter, "~> 0.5.8"},
      # Livebook tools, todo: use node connect instead
      {:kino, "~> 0.16.0", only: [:dev]},
      {:kino_vega_lite, "~> 0.1.11", only: [:dev]}
    ] ++
      local_deps([
        :bandit,
        :thousand_island,
        :req,
        :mint_web_socket
      ])
  end

  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  ## Local deps to debug and learning and run test

  def local_deps(names) when is_list(names) do
    names |> Enum.map(&local_dep/1)
  end

  def local_dep(name) when is_atom(name) do
    dep_path = Path.join(local_dep_root(), name |> to_string)
    # todo: auto clone from github or hex.pm if missing
    # https://github.com/hexpm/hex/blob/main/lib/mix/tasks/hex.info.ex#L28
    # https://github.com/hexpm/hex/blob/main/lib/hex/api/package.ex
    {name, path: dep_path, override: true}
  end

  def local_dep_root, do: System.get_env("LOCAL_DEP_PATH", "deps.local")
end
