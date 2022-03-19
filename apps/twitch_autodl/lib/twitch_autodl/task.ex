defmodule TwitchAutodl.Task do
  alias TwitchAutodl.Task.State

  @tasks [
    TwitchAutodl.Task.VideoData,
    TwitchAutodl.Task.Playlist,
    TwitchAutodl.Task.Directory,
    TwitchAutodl.Task.ChunkDownload,
    TwitchAutodl.Task.Concat
    #    :remux,
    #    :move,
    #    :cleanup
  ]

  def run(%State{next_tasks: []}), do: :finished
  def run(%State{next_tasks: nil} = state), do: %{state | next_tasks: @tasks} |> run()

  def run(%State{next_tasks: next_tasks} = state) do
    [task | remaining_tasks] = next_tasks

    case task.run(state) do
      {:ok, new_state} -> {:ok, %{new_state | next_tasks: remaining_tasks}}
      error -> error
    end
  end
end
