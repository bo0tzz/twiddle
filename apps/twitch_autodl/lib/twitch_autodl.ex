defmodule TwitchAutodl do
  use GenServer
  require Logger

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    path = TwitchAutodl.Settings.download_folder()
    {:ok, %{path: path}}
  end

  # TODO: Pull genserver out into separate module
  @impl true
  def handle_call({:download, url}, _from, %{path: path} = state) do
    # TODO: Check if task already exists
    result =
      with {:ok, %{host: host, path: url_path}} <- as_uri(url),
           :ok <- validate_host(host),
           {:ok, id} <- get_vod_id(url_path),
           state <- TwitchAutodl.Task.State.new(id, path),
           state <- TwitchAutodl.Task.initialize(state) do
        Logger.info("Creating new download task for vod ID #{id}")
        :ok = TwitchAutodl.Task.State.save_task(state)
        {:ok, id}
      end

    {:reply, result, state}
  end

  def download(url) do
    GenServer.call(__MODULE__, {:download, url})
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
