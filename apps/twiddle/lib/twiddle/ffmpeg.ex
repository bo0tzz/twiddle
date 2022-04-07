defmodule Twiddle.FFmpeg do
  require Logger

  alias Twiddle.FFmpeg
  alias Twiddle.FFmpeg.Parser

  defstruct [:pids, :status, :update_progress]

  @concat_cmd 'ffmpeg -i index.m3u8 -codec copy index.ts -y'
  @remux_cmd 'ffmpeg -i index.ts -codec copy index.mkv -y'
  @subs_cmd 'ffmpeg -f lavfi -i "movie=index.ts[out0+subcc]" index.srt -y'

  def concatenate_chunks(path, duration, update_progress) do
    run(@concat_cmd, path, duration, update_progress)
  end

  def remux(path, duration, update_progress) do
    run(@remux_cmd, path, duration, update_progress)
  end

  def extract_subs(path, duration, update_progress) do
    run(@subs_cmd, path, duration, update_progress)
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
