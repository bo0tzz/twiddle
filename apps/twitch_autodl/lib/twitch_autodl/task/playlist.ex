defmodule TwitchAutodl.Task.Playlist do
  alias TwitchAutodl.Task.State
  alias TwitchAutodl.Twitch.Vod
  alias TwitchAutodl.M3U8

  def work(%State{id: id, data: data} = state) do
    playlist = Vod.playlist(id)
    m3u8 = M3U8.new(playlist)
    data = Map.put(data, :m3u8, m3u8)
    %{state | data: data}
  end

end
