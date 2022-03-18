defmodule TwitchAutodl.Twitch.Gql do
  @video_query """
    query Video($id: ID) {
      video(id: $id) {
        title
        lengthSeconds
      }
    }
  """

  def get_video(id) do
    {:ok, %{body: %{"data" => %{"video" => video}}}} = Neuron.query(@video_query, %{id: id})
    video
  end
end
