defmodule TwitchAutodl.Task.VideoData do
  alias TwitchAutodl.Task.State

  def work(%State{id: id, data: data} = state) do
    %{"title" => title, "lengthSeconds" => duration} = TwitchAutodl.Twitch.Gql.get_video(id)
    data = data |> Map.put(:title, title) |> Map.put(:duration, duration)
    %{state | data: data}
  end

end
