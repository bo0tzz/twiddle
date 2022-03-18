defmodule TwitchAutodl.Task do
  @tasks [
    TwitchAutodl.Task.VideoData,
    TwitchAutodl.Task.Playlist,
    :mkdir,
    :chunk_download,
    :concat,
    :remux,
    :move,
    :cleanup
  ]

end
