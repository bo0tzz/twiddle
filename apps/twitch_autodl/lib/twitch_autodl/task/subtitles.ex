defmodule TwitchAutodl.Task.Subtitles do
  alias TwitchAutodl.Task.State

  def run(%State{data: %{duration: duration, working_dir: path}, options: options} = state) do
    if options[:extract_subtitles] do
      :done = TwitchAutodl.FFmpeg.extract_subs(path, duration)
    end

    {:ok, state}
  end
end
