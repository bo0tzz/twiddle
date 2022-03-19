defmodule TwitchAutodl.Task.Concat do
  alias TwitchAutodl.Task.State

  def run(%State{data: %{duration: duration, working_dir: path}} = state) do
    TwitchAutodl.FFmpeg.concatenate_chunks(path, duration)

    receive do
      {:done, ^path} -> {:ok, state}
    end
  end
end
