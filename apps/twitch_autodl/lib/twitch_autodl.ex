defmodule TwitchAutodl do
  @moduledoc """
  TwitchAutodl keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def download_vod(id, base_path) do
    path = Path.absname(base_path)

    m3u8 =
      TwitchAutodl.Twitch.Vod.playlist(id)
      |> TwitchAutodl.M3U8.new()

    TwitchAutodl.Download.download_chunks(m3u8, "chunked", base_path)
  end
end
