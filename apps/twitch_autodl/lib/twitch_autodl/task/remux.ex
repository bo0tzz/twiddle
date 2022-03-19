defmodule TwitchAutodl.Task.Remux do
  alias TwitchAutodl.Task.State

  def run(%State{data: %{duration: duration, working_dir: path}} = state) do
    TwitchAutodl.FFmpeg.remux(path, duration)

    receive do
      {:done, ^path} -> {:ok, state}
    end
  end
end
