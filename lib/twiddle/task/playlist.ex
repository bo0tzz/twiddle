defmodule Twiddle.Task.Playlist do
  alias Twiddle.Task.State
  alias Twiddle.Pogu.Vod
  alias Twiddle.M3U8

  def run(%State{id: id, data: data} = state) do
    playlist = Vod.playlist(id)
    m3u8 = M3U8.new(playlist)
    data = Map.put(data, :m3u8, m3u8)
    {:ok, %{state | data: data}}
  end
end
