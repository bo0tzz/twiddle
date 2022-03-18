defmodule TwitchAutodl.FFmpeg.Server do
  use GenServer
  require Logger
  alias TwitchAutodl.FFmpeg.Server

  defstruct [:path, :pids, :status, :parent]

  @duration_regex ~r/Duration: (\d*):(\d*):(\d*).(\d*)/
  @time_regex ~r/time=(\d*):(\d*):(\d*).(\d*)/

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init({cmd, path, parent}) do
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
       status: %{},
       parent: parent
     }}
  end

  @impl true
  def handle_info({:stderr, _, data}, state) do
    state = process_ffmpeg_output(data, state)
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _, :process, _, :normal}, %Server{parent: parent, path: path} = state) do
    Logger.info("Finished")
    send(parent, {:done, path})
    {:stop, :normal, state}
  end

  def process_ffmpeg_output("Input #0, " <> _ = output, %Server{status: status} = state) do
    duration = Regex.run(@duration_regex, output, capture: :all_but_first)
               |> as_duration
    status = Map.put(status, :duration, duration)
    %{state | status: status}
  end

  def process_ffmpeg_output("frame= " <> _ = output, %Server{status: status} = state) do
    progress = Regex.run(@time_regex, output, capture: :all_but_first)
    |> as_duration
    status = Map.put(status, :progress, progress)
    log_progress(status)
    %{state | status: status}
  end

  def process_ffmpeg_output(_output, state), do: state

  def log_progress(status) do
    with {:ok, duration} <- Map.fetch(status, :duration),
         {:ok, progress} <- Map.fetch(status, :progress) do
      percent = Timex.Duration.to_seconds(progress) / Timex.Duration.to_seconds(duration) * 100 |> round()
      Logger.info("Progress: #{percent}%")
    end
  end

  def as_duration(time) do
    time
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
    |> Timex.Duration.from_clock()
  end
end
