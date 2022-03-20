defmodule TwitchAutodl.Task.Remux do
  alias TwitchAutodl.Task.State

  def run(%State{data: %{duration: duration, working_dir: path}} = state) do
    :done = TwitchAutodl.FFmpeg.remux(path, duration)
    {:ok, state}
  end
end
