defmodule Twiddle.Task.MoveFiles do
  require Logger

  alias Twiddle.Task.State

  def run(%State{data: %{title: title, working_dir: path}, options: options} = state) do
    filename = String.replace(title, "/", "-")

    if options[:extract_subtitles] do
      case move_file(path, filename, ".srt") do
        {:error, error} -> Logger.warn("Error while moving file #{filename}.srt: #{error}")
        :ok -> :ok
      end
    end

    case move_file(path, filename, ".mkv") do
      :ok -> {:ok, state}
      error -> error
    end
  end

  def move_file(path, filename, extension) do
    to_filename = filename <> extension
    to_path = Path.join([path, "..", to_filename])

    from_filename = "index" <> extension
    from_path = Path.join(path, from_filename)
    File.rename(from_path, to_path)
  end
end
