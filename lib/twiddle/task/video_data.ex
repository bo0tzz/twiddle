defmodule Twiddle.Task.VideoData do
  alias Twiddle.Task.State

  def run(%State{id: id, data: data} = state) do
    case Twiddle.Gql.get_video(id) do
      nil ->
        {:error, "Video ID not found"}

      %{"title" => title, "lengthSeconds" => duration, "animatedPreviewURL" => animatedPreviewURL} ->
        data =
          data
          |> Map.put(:title, title)
          |> Map.put(:duration, duration)
          |> Map.put(:animatedPreviewURL, animatedPreviewURL)

        {:ok, %{state | data: data}}
    end
  end
end
