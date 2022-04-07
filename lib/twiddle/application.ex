defmodule Twiddle.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Neuron.Config.set(url: "https://gql.twitch.tv/gql")
    Neuron.Config.set(headers: ["Client-Id": "kimne78kx3ncx6brgo4mv6wki5h1ko"])

    children = [
      # Start the PubSub system
      Twiddle.Settings,
      {Phoenix.PubSub, name: Twiddle.PubSub},
      Twiddle.Task.State,
      Twiddle.Jobs,

      TwiddleWeb.Telemetry,
      TwiddleWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Twiddle.Supervisor)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TwiddleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
