defmodule TwitchAutodl.Task.Concat do
  alias TwitchAutodl.Task.State

  def run(%State{id: id, data: %{duration: duration, working_dir: path}} = state) do
    :done =
      TwitchAutodl.FFmpeg.concatenate_chunks(
        path,
        duration,
        &State.set_progress(id, __MODULE__, &1)
      )

    {:ok, state}
  end
end
