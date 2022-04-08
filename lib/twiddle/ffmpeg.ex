defmodule Twiddle.FFmpeg do
  require Logger

  alias Twiddle.FFmpeg
  alias Twiddle.FFmpeg.Parser

  defstruct [:pids, :status, :update_progress]

  @concat ["-i", "index.m3u8", "-codec", "copy", "index.ts", "-y"]
  @remux ["-i", "index.ts", "-codec", "copy", "index.mkv", "-y"]
  @subs ["-f", "lavfi", "-i", "movie=index.ts[out0+subcc]", "index.srt", "-y"]

  def concatenate_chunks(path, duration, update_progress) do
    ffmpeg_cmd(@concat)
    |> run(path, duration, update_progress)
  end

  def remux(path, duration, update_progress) do
    ffmpeg_cmd(@remux)
    |> run(path, duration, update_progress)
  end

  def extract_subs(path, duration, update_progress) do
    ffmpeg_cmd(@subs)
    |> run(path, duration, update_progress)
  end

  defp ffmpeg_cmd(args) do
    bin = Application.fetch_env!(:twiddle, __MODULE__)[:binary]
    [bin | args]
  end

  def run(command, path, duration_hint, update_progress) do
    options = [
      :stderr,
      :monitor,
      cd: String.to_charlist(path)
    ]

    {:ok, pid, ospid} = :exec.run(command, options)

    state = %FFmpeg{
      pids: {pid, ospid},
      status: Parser.new(duration_hint),
      update_progress: update_progress
    }

    receive_loop(state)
  end

  def receive_loop(
        %FFmpeg{status: status, pids: {pid, ospid}, update_progress: update_progress} = state
      ) do
    receive do
      {:stderr, ^ospid, data} ->
        status = Parser.parse(data, status)
        Parser.progress(status) |> update_progress.()
        receive_loop(%{state | status: status})

      {:DOWN, ^ospid, :process, ^pid, :normal} ->
        :done

      other ->
        Logger.warn("Received unexpected ffmpeg message: #{inspect(other)}")
        other
    end
  end
end
