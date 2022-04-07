defmodule Twiddle.Task do
  require Logger

  alias Twiddle.Task.State

  @tasks [
    Twiddle.Task.VideoData,
    Twiddle.Task.Playlist,
    Twiddle.Task.Directory,
    Twiddle.Task.ChunkDownload,
    Twiddle.Task.Concat,
    Twiddle.Task.Remux,
    Twiddle.Task.Subtitles,
    Twiddle.Task.MoveFiles,
    Twiddle.Task.Cleanup
  ]

  def finished?(%State{next_tasks: []}), do: true
  def finished?(_), do: false

  def has_errors?(%State{errors: errors}) when length(errors) > 0, do: true
  def has_errors?(_), do: false

  def run(%State{next_tasks: []}), do: :finished
  def run(%State{next_tasks: nil} = state), do: {:ok, %{state | next_tasks: @tasks}}

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
