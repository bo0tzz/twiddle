defmodule TwitchAutodl.Download do
  require Logger
  alias TwitchAutodl.M3U8

  def download_chunks(m3u8, quality, base_path, id) do
    base_url = M3U8.base_url(m3u8, quality)

    chunk_to_job = fn chunk ->
      url = Path.join(base_url, chunk) |> String.to_charlist()
      path = Path.join(base_path, chunk) |> String.to_charlist()
      {url, path}
    end

    index = M3U8.chunks(m3u8, quality)

    Path.join(base_path, "index.m3u8")
    |> File.write(index)

    all_chunks = M3U8.get_playlist_entries(index)

    chunk_count = Enum.count(all_chunks)

    all_chunks
    |> Enum.map(chunk_to_job)
    |> Task.async_stream(&download_chunk/1, timeout: :infinity)
    |> Enum.reduce(0, fn _, completed ->
      completed = completed + 1
      progress = completed / chunk_count * 100
      TwitchAutodl.Task.State.set_progress(id, :download, progress)
      completed
    end)
    |> Stream.run()
  end

  defp download_chunk({url, path}) do
    {:ok, :saved_to_file} = :httpc.request(:get, {url, []}, [], stream: path)
  end
end
