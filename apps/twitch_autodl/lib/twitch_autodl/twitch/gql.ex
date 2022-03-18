defmodule TwitchAutodl.Twitch.Gql do
  @video_query """
    query Video($id: ID) {
      video(id: $id) {
        id
        title
        createdAt
      }
    }
  """

  def get_video(id) when is_integer(id), do: Integer.to_string(id) |> get_video()

  def get_video(id) do
    {:ok, %{body: %{"data" => %{"video" => video}}}} = Neuron.query(@video_query, %{id: id})
    video
  end
end
