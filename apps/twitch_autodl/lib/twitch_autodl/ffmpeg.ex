defmodule TwitchAutodl.FFmpeg do
  alias TwitchAutodl.FFmpeg.Server

  @concat_cmd 'ffmpeg -i index.m3u8 -codec copy index.ts'
  @remux_cmd 'ffmpeg -i index.ts -codec copy index.mkv'
  @subs_cmd 'ffmpeg -f lavfi -i "movie=index.ts[out0+subcc]" index.srt'

  def concatenate_chunks(path, duration) do
    Server.start_link({@concat_cmd, path, duration, self()})
  end

  def remux(path, duration) do
    Server.start_link({@remux_cmd, path, duration, self()})
  end

  def extract_subs(path, duration) do
    Server.start_link({@subs_cmd, path, duration, self()})
  end
end
