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
  def init({cmd, path, expected_duration, parent}) do
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
       status: %{duration: Timex.Duration.from_seconds(expected_duration)},
       parent: parent
     }}
  end

  @impl true
  def handle_info({:stderr, _, data}, state) do
    Logger.debug("FFmpeg message: #{data}")
    state = process_ffmpeg_output(data, state)
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _, :process, _, :normal}, %Server{parent: parent, path: path} = state) do
    Logger.info("Finished")
    send(parent, {:done, path})
    {:stop, :normal, state}
  end

  def process_ffmpeg_output("frame=" <> _ = output, state), do: parse_time_remaining(output, state)
  def process_ffmpeg_output("size=" <> _ = output, state), do: parse_time_remaining(output, state)
# TODO: Proper ffmpeg progress parsing
  def parse_time_remaining(output, state) do
    progress =
      Regex.run(@time_regex, output, capture: :all_but_first)
      |> as_duration

    status = Map.put(status, :progress, progress)
    log_progress(status)
    %{state | status: status}
  end

  def process_ffmpeg_output(output, %Server{status: status} = state) do
    if String.contains?(output, "Duration") do
      duration =
        Regex.run(@duration_regex, output, capture: :all_but_first)
        |> as_duration
        |> case do
          nil -> Map.get(status, :duration)
          duration -> duration
        end

      Logger.info("Duration of file being processed: #{duration |> Timex.Duration.to_string()}")

      status = Map.put(status, :duration, duration)
      %{state | status: status}
    else
      #      Logger.debug("Unknown ffmpeg message: #{inspect(output)}")
      state
    end
  end

  def log_progress(status) do
    {:ok, duration} = Map.fetch(status, :duration)
    {:ok, progress} = Map.fetch(status, :progress)

    percent =
      (Timex.Duration.to_seconds(progress) / Timex.Duration.to_seconds(duration) * 100)
      |> round()

    Logger.info("Progress: #{percent}%")
  end

  def as_duration(nil), do: nil

  def as_duration(time) do
    time
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
    |> Timex.Duration.from_clock()
  end
end
