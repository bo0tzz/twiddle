defmodule TwitchAutodl.FFmpeg do
  alias TwitchAutodl.FFmpeg.Server

  @concat_cmd 'ffmpeg -i index.m3u8 -codec copy index.ts'
  @remux_cmd 'ffmpeg -i index.ts -f lavfi -i "movie=index.ts[out0+subcc]" -map 0 -map 1:s -codec copy -codec:s srt index.mkv'

  def concatenate_chunks(path) do
    Server.start_link({@concat_cmd, path, self()})
  end

  def remux(path) do
    Server.start_link({@remux_cmd, path, self()})
  end
end
