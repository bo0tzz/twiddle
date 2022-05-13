defmodule Twiddle.Download do
  require Logger
  alias Twiddle.M3U8

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
      if report?(progress), do: Twiddle.Task.State.set_progress(id, :download, progress)
      completed
    end)
  end

  def report?(progress), do: 0 == round(progress) |> Integer.mod(5)

  defp download_chunk({url, path}) do
    case already_downloaded?({url, path}) do
      true ->
        Logger.debug("Skipping #{url}: Already downloaded")

      false ->
        # TODO: byte-range based downloads instead
        File.rm(path)
        {:ok, :saved_to_file} = :httpc.request(:get, {url, []}, [], stream: path)
    end
  end

  def already_downloaded?({url, path}) do
    with {:ok, %{size: size}} <- File.stat(path),
         {:ok, {_, headers, _}} <- :httpc.request(:head, {url, []}, [], []),
         {:ok, length_bin} <- proplist_get(headers, 'content-length'),
         {length, _} when is_integer(length) <- :string.to_integer(length_bin) do
      length == size
    else
      _ -> false
    end
  end

  defp proplist_get(list, value) do
    case :proplists.get_value(value, list) do
      :undefined -> {:error, :undefined}
      value -> {:ok, value}
    end
  end
end
