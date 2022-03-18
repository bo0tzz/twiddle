defmodule TwitchAutodl.MixProject do
  use Mix.Project

  def project do
    [
      app: :twitch_autodl,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {TwitchAutodl.Application, []},
      extra_applications: [:logger, :runtime_tools, :inets, :ssl]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix_pubsub, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17"},
      {:erlexec, "~> 1.0"},
      {:timex, "~> 3.0"},
      {:neuron, "~> 5.0.0"},

      # TODO: Use proper dependency
      {:config_server, path: "../../../config_server"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get"]
    ]
  end
end
