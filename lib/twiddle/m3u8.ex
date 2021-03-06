defmodule Twiddle.M3U8 do
  @moduledoc false

  alias Twiddle.M3U8

  defstruct [:base, :qualities, :filename]

  def new(playlist), do: get_playlist_entries(playlist) |> new_from_urls()

  def new_from_urls(url) when not is_list(url), do: new_from_urls([url])

  def new_from_urls(urls) do
    parts = Enum.map(urls, &snip_url/1)
    {filename, _, base} = List.first(parts)
    qualities = ["chunked" | Enum.map(parts, &elem(&1, 1))] |> Enum.uniq()

    %M3U8{
      base: base,
      qualities: qualities,
      filename: filename
    }
  end

  def build_urls(%M3U8{qualities: qualities} = m3u8) do
    Enum.map(qualities, &build_url(m3u8, &1))
  end

  defp build_url(%M3U8{base: base, filename: file}, quality) do
    parts = Path.split(base.path) ++ [quality, file]
    path = Path.join(parts)
    %{base | path: path} |> URI.to_string()
  end

  def get_playlist_entries(playlist) do
    playlist
    |> String.split()
    |> Enum.reject(&String.starts_with?(&1, "#"))
  end

  def chunks(m3u8, quality) do
    playlist_url = build_url(m3u8, quality)
    Tesla.get!(playlist_url).body
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
