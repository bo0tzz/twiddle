defmodule TwitchAutodl.Application do
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
      {Phoenix.PubSub, name: TwitchAutodl.PubSub},
      TwitchAutodl.Task.State
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: TwitchAutodl.Supervisor)
  end
end
