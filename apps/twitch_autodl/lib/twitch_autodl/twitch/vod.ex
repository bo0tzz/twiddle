defmodule TwitchAutodl.Twitch.Vod do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://pogu.live/api/get-video/")

  def playlist(vod_id) when is_integer(vod_id), do: Integer.to_string(vod_id) |> playlist()
  def playlist(vod_id) do
    {:ok, resp} = get(vod_id <> ".m3u8")
    resp.body
  end
end
