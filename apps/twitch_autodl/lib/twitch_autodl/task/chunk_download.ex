defmodule TwitchAutodl.Task.ChunkDownload do
  alias TwitchAutodl.Task.State

  def run(
        %State{
          id: id,
          data: %{working_dir: path, m3u8: %{qualities: [quality | _]} = m3u8}
        } = state
      ) do
    :ok = TwitchAutodl.Download.download_chunks(m3u8, quality, path, id)
    {:ok, state}
  end
end
