defmodule TwitchAutodl.Task.Subtitles do
  alias TwitchAutodl.Task.State

  def run(%State{data: %{duration: duration, working_dir: path}} = state) do
    TwitchAutodl.FFmpeg.extract_subs(path, duration)
    {:ok, state}
  end
end
