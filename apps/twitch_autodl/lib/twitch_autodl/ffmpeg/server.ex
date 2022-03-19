defmodule TwitchAutodl.FFmpeg.Server do
  use GenServer
  require Logger
  alias TwitchAutodl.FFmpeg.Server
  alias TwitchAutodl.FFmpeg.Parser

  defstruct [:path, :pids, :status, :parent]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init({cmd, path, duration_hint, parent}) do
    options = [
      :stderr,
      :monitor,
      cd: String.to_charlist(path)
    ]

    {:ok, pid, ospid} = :exec.run(cmd, options)

    {:ok,
     %Server{
       path: path,
       pids: {pid, ospid},
       status: Parser.new(duration_hint),
       parent: parent
     }}
  end

  @impl true
  def handle_info({:stderr, _, data}, %{status: status} = state) do
    status = Parser.parse(data, status)
    {:noreply, %{state | status: status}}
  end

  @impl true
  def handle_info({:DOWN, _, :process, _, :normal}, %Server{parent: parent, path: path} = state) do
    send(parent, {:done, path})
    {:stop, :normal, state}
  end
end
