defmodule TwitchAutodl.FFmpeg.Parser do
  require Logger

  alias Timex.Duration
  alias TwitchAutodl.FFmpeg.Parser

  defstruct [:duration, :progress]

  @duration_regex ~r/Duration: (\d*):(\d*):(\d*).(\d*)/
  @time_regex ~r/time=(\d*):(\d*):(\d*).(\d*)/

  def new(duration_hint) do
    %Parser{
      duration: Duration.from_seconds(duration_hint)
    }
  end

  def progress(%Parser{progress: nil}), do: :unknown

  def progress(%Parser{progress: p, duration: d}),
    do:
      (Duration.to_seconds(p) / Duration.to_seconds(d) * 100)
      |> Float.round(2)

  def parse_progress(log, state) do
    progress =
      Regex.run(@time_regex, log, capture: :all_but_first)
      |> as_duration()

    %{state | progress: progress}
  end

  def parse("frame=" <> _ = log, state), do: parse_progress(log, state)
  def parse("size=" <> _ = log, state), do: parse_progress(log, state)

  def parse(log, state) do
    case Regex.run(@duration_regex, log, capture: :all_but_first) do
      nil -> state
      timestamp -> %{state | duration: as_duration(timestamp)}
    end
  end

  def as_duration(timestamp) do
    timestamp
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
    |> Timex.Duration.from_clock()
  end
end
