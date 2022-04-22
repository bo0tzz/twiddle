defmodule Twiddle.Task.Playlist do
  alias Twiddle.Task.State
  alias Twiddle.Vod
  alias Twiddle.M3U8

  def run(%State{data: data} = state) do
    m3u8 = Vod.playlist_url(data) |> M3U8.new_from_urls()
    data = Map.put(data, :m3u8, m3u8)
    {:ok, %{state | data: data}}
  end
end
