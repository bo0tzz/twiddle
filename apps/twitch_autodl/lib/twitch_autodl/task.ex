defmodule TwitchAutodl.Task do
  require Logger

  alias TwitchAutodl.Task.State

  @tasks [
    TwitchAutodl.Task.VideoData,
    TwitchAutodl.Task.Playlist,
    TwitchAutodl.Task.Directory,
    TwitchAutodl.Task.ChunkDownload,
    TwitchAutodl.Task.Concat,
    TwitchAutodl.Task.Remux,
    TwitchAutodl.Task.Subtitles,
    TwitchAutodl.Task.MoveFiles,
    TwitchAutodl.Task.Cleanup
  ]

  def initialize(%State{next_tasks: nil} = state), do: %{state | next_tasks: @tasks}
  def initialize(_), do: {:error, "Already initialized"}

  def run(%State{next_tasks: []}), do: :finished
  def run(%State{next_tasks: nil}), do: {:error, "No tasks"}

  def run(%State{id: id, next_tasks: next_tasks, stats: stats} = state) do
    [task | remaining_tasks] = next_tasks

    Logger.debug("[#{id}] Running task #{task}")
    {time, result} = :timer.tc(task, :run, [state])
    stats = Map.put(stats, task, time)

    case result do
      {:ok, new_state} -> {:ok, %{new_state | next_tasks: remaining_tasks, stats: stats}}
      error -> error
    end
  end

  def run_all(state) do
    case run(state) do
      {:ok, new_state} -> run_all(new_state)
      :finished -> {:finished, state}
      error -> error
    end
  end
end
