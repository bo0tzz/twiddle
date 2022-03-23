defmodule TwitchAutodl do
  use GenServer
  require Logger

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(path) do
    {:ok, %{path: path}}
  end

  @impl true
  def handle_call({:download, url}, _from, %{path: path} = state) do
    result = with {:ok, %{host: host, path: url_path}} <- as_uri(url),
         :ok <- validate_host(host),
         {:ok, id} <- get_vod_id(url_path) do
      Logger.info("Creating new download task for vod ID #{id}")
      TwitchAutodl.Task.State.new(id, path)
      |> TwitchAutodl.Task.State.save_task()
    end
    {:reply, result, state}
  end

  def download(url) do
    GenServer.call(__MODULE__, {:download, url})
  end

  def as_uri(url) do
    case URI.new(url) do
      {:error, char} -> {:error, "Invalid URL content: " <> char}
      ok -> ok
    end
  end

  def validate_host("www." <> host), do: validate_host(host)
  def validate_host("twitch.tv"), do: :ok
  def validate_host(nil), do: {:error, "Missing host"}
  def validate_host(host), do: {:error, "Unsupported host: " <> IO.inspect(host)}

  def get_vod_id(path) when is_binary(path), do: Path.split(path) |> get_vod_id()
  def get_vod_id(["/" | path]), do: get_vod_id(path)
  def get_vod_id(["videos", id]), do: {:ok, id}
  def get_vod_id(_path), do: {:error, "Not a video URL"}

end
