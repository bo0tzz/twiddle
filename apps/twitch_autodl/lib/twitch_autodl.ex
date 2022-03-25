defmodule TwitchAutodl do
  require Logger

  def download(url) do
    path = TwitchAutodl.Settings.download_folder()
    opts = [
      extract_subtitles: TwitchAutodl.Settings.extract_subtitles()
    ]

    # TODO: Check if task already exists
    with {:ok, %{host: host, path: url_path}} <- as_uri(url),
         :ok <- validate_host(host),
         {:ok, id} <- get_vod_id(url_path),
         state <- TwitchAutodl.Task.State.new(id, path, opts) do
      Logger.info("Creating new download task for vod ID #{id}")
      :ok = TwitchAutodl.Task.State.save_task(state)
      {:ok, id}
    end
  end

  def get_tasks(), do: TwitchAutodl.Task.State.get_tasks()
  def get_task(id), do: TwitchAutodl.Task.State.get_task(id)

  defp as_uri(url) do
    case URI.new(url) do
      {:error, char} -> {:error, "Invalid URL content: " <> char}
      ok -> ok
    end
  end

  defp validate_host("www." <> host), do: validate_host(host)
  defp validate_host("twitch.tv"), do: :ok
  defp validate_host(nil), do: {:error, "Missing host"}
  defp validate_host(host), do: {:error, "Unsupported host: " <> host}

  defp get_vod_id(path) when is_binary(path), do: Path.split(path) |> get_vod_id()
  defp get_vod_id(["/" | path]), do: get_vod_id(path)
  defp get_vod_id(["videos", id]), do: {:ok, id}
  defp get_vod_id(_path), do: {:error, "Not a video URL"}
end
