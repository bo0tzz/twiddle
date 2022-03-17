defmodule TwitchAutodl.Download do
  require Logger
  alias TwitchAutodl.M3U8

  def download_chunks(m3u8, quality, base_path) do
    base_url = M3U8.base_url(m3u8, quality)

    chunk_to_job = fn chunk ->
      url = Path.join(base_url, chunk) |> String.to_charlist()
      path = Path.join(base_path, chunk) |> String.to_charlist()
      {url, path}
    end

    index = M3U8.chunks(m3u8, quality)

    Path.join(base_path, "index.m3u8")
    |> File.write(index)

    M3U8.get_playlist_entries(index)
    |> Enum.map(chunk_to_job)
    |> Task.async_stream(&download_chunk/1, timeout: :infinity)
    |> Stream.run()
  end

  defp download_chunk({url, path}) do
    Logger.debug("Downloading chunk #{url} to path #{path}")
    {:ok, :saved_to_file} = :httpc.request(:get, {url, []}, [], stream: path)
  end
end
