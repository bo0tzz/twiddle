defmodule TwitchAutodl.Download do
  require Logger
  alias TwitchAutodl.M3U8

  defstruct [:base, :chunks, :path]

  def download_chunks(m3u8, quality, base_path) do
    base_url = M3U8.base_url(m3u8, quality)

    chunk_to_job = fn chunk ->
      url = Path.join(base_url, chunk) |> String.to_charlist()
      path = Path.join(base_path, chunk) |> String.to_charlist()
      {url, path}
    end

    M3U8.chunks(m3u8, quality)
    |> Enum.map(chunk_to_job)
    |> Task.async_stream(&download_chunk/1, timeout: :infinity)
    |> Stream.run()
  end

  defp download_chunk({url, path}) do
    Logger.debug("Downloading chunk #{url} to path #{path}")
    {:ok, :saved_to_file} = :httpc.request(:get, {url, []}, [], stream: path)
  end
end
