defmodule TwitchAutodl.M3U8 do
  @moduledoc false

  alias TwitchAutodl.M3U8

  defstruct [:base, :qualities, :playlist_file]

  def new(playlist) do
    urls = get_playlist_entries(playlist)

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

  defp get_playlist_entries(playlist) do
    playlist
    |> String.split()
    |> Enum.reject(&String.starts_with?(&1, "#"))
  end

  def chunks(m3u8, quality) do
    playlist_url = M3U8.build_url(m3u8, quality)
    {:ok, playlist} = Tesla.get(playlist_url)
    M3U8.get_playlist_entries(playlist.body)
  end

  def base_url(%M3U8{base: base}, quality), do: URI.to_string(base) |> Path.join(quality)

  defp snip_url(url) do
    {:ok, uri} = URI.new(url)
    [file, quality | rest] = Path.split(uri.path) |> Enum.reverse()
    path = Enum.reverse(rest) |> Path.join()
    base = %{uri | path: path}
    {file, quality, base}
  end
end
