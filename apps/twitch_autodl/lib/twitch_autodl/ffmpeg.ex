defmodule TwitchAutodl.FFmpeg do
  require Logger

  alias TwitchAutodl.FFmpeg
  alias TwitchAutodl.FFmpeg.Parser

  defstruct [:pids, :status]

  @concat_cmd 'ffmpeg -i index.m3u8 -codec copy index.ts'
  @remux_cmd 'ffmpeg -i index.ts -codec copy index.mkv'
  @subs_cmd 'ffmpeg -f lavfi -i "movie=index.ts[out0+subcc]" index.srt'

  def concatenate_chunks(path, duration) do
    run(@concat_cmd, path, duration)
  end

  def remux(path, duration) do
    run(@remux_cmd, path, duration)
  end

  def extract_subs(path, duration) do
    run(@subs_cmd, path, duration)
  end

  def run(command, path, duration_hint) do
    options = [
      :stderr,
      :monitor,
      cd: String.to_charlist(path)
    ]

    {:ok, pid, ospid} = :exec.run(command, options)

    state = %FFmpeg{
      pids: {pid, ospid},
      status: Parser.new(duration_hint)
    }

    receive_loop(state)
  end

  def receive_loop(%FFmpeg{status: status, pids: {pid, ospid}} = state) do
    receive do
      {:stderr, ^ospid, data} ->
        status = Parser.parse(data, status)
        receive_loop(%{state | status: status})

      {:DOWN, ^ospid, :process, ^pid, :normal} ->
        :done

      other ->
        Logger.warn("Received unexpected ffmpeg message: #{inspect(other)}")
        other
    end
  end
end