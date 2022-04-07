defmodule Twiddle.Pogu.Vod do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://pogu.live/api/get-video/")

  def playlist(vod_id) do
    {:ok, resp} = get(vod_id <> ".m3u8")
    resp.body
  end
end
