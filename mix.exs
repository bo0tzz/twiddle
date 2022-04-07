defmodule Twiddle.MixProject do
  use Mix.Project

  def project do
    [
      app: :twiddle,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.6.6"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.17.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.6"},
      {:esbuild, "~> 0.3", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:ex_fontawesome, "~> 0.7.0"},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      # TODO: This formatter will be included in a new liveview release
      {:heex_formatter, github: "feliperenan/heex_formatter", only: :dev},
      {:phoenix_pubsub, "~> 2.0"},
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17"},
      {:erlexec, "~> 1.0"},
      {:timex, "~> 3.0"},
      {:neuron, "~> 5.0.0"},
      {:maptu, "~> 1.0"},
      {:config_server, git: "https://github.com/bo0tzz/config_server.git"}
    ]
  end

  def application do
    [
      mod: {Twiddle.Application, []},
      extra_applications: [:logger, :runtime_tools, :inets, :ssl]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  #
  # Aliases listed here are available only for this project
  # and cannot be accessed from applications inside the apps/ folder.
  defp aliases do
    [
      setup: ["deps.get"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
