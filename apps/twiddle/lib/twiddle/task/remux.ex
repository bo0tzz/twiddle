defmodule Twiddle.Task.Remux do
  alias Twiddle.Task.State

  def run(%State{id: id, data: %{duration: duration, working_dir: path}} = state) do
    :done = Twiddle.FFmpeg.remux(path, duration, &State.set_progress(id, __MODULE__, &1))
    {:ok, state}
  end
end
