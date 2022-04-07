defmodule Twiddle.Task.Subtitles do
  alias Twiddle.Task.State

  def run(
        %State{id: id, data: %{duration: duration, working_dir: path}, options: options} = state
      ) do
    if options[:extract_subtitles] do
      :done = Twiddle.FFmpeg.extract_subs(path, duration, &State.set_progress(id, __MODULE__, &1))
    end

    {:ok, state}
  end
end
