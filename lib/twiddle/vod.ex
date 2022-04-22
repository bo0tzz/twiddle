defmodule Twiddle.Vod do
  def playlist_url(%{animatedPreviewURL: previewURL} = _videoData) do
    {:ok, uri} = URI.new(previewURL)

    playlist_path =
      uri.path
      |> Path.split()
      |> Enum.take(2)
      |> then(&(&1 ++ ["chunked", "index-dvr.m3u8"]))
      |> Path.join()

    %{uri | path: playlist_path} |> URI.to_string()
  end
end
