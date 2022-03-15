defmodule TwitchAutodl.M3U8 do
  @moduledoc false

  alias TwitchAutodl.M3U8

  defstruct [:base, :qualities, :playlist_file, :chunks]

  def new(playlist) do
    urls = get_urls(playlist)

    parts = Enum.map(urls, &snip_url/1)
    {playlist_file, _, base} = List.first(parts)
    qualities = ["chunked" | Enum.map(parts, &elem(&1, 1))]

    %M3U8{
      base: base,
      qualities: qualities,
      playlist_file: playlist_file
    }
  end

  def build_urls(%M3U8{qualities: qualities} = m3u8) do
    Enum.map(qualities, &build_url(m3u8, &1))
  end

  defp build_url(%M3U8{base: base, playlist_file: file}, quality) do
    parts = Path.split(base.path) ++ [quality, file]
    path = Path.join(parts)
    %{base | path: path} |> URI.to_string()
  end

  defp get_urls(playlist) do
    playlist
    |> String.split()
    |> Enum.reject(&String.starts_with?(&1, "#"))
  end

  defp snip_url(url) do
    {:ok, uri} = URI.new(url)
    [file, quality | rest] = Path.split(uri.path) |> Enum.reverse()
    path = Enum.reverse(rest) |> Path.join()
    base = %{uri | path: path}
    {file, quality, base}
  end
end
