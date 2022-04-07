defmodule Twiddle.Jobs do
  use GenServer
  require Logger
  alias Twiddle.Jobs
  alias Twiddle.Task.State

  defstruct jobs: %{}

  @tick_interval 10_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(_arg) do
    Process.send_after(self(), :tick, @tick_interval)
    {:ok, %Jobs{}, {:continue, :start_jobs}}
  end

  @impl true
  def handle_continue(:start_jobs, %{jobs: jobs} = state) do
    running_jobs = Map.keys(jobs)

    new_jobs =
      State.get_tasks()
      |> Enum.reject(&Twiddle.Task.finished?/1)
      |> Enum.reject(&Twiddle.Task.has_errors?/1)
      |> Enum.reject(&(&1.id in running_jobs))
      |> Enum.map(&start_task/1)

    {:noreply, %{state | jobs: Enum.into(new_jobs, jobs)}}
  end

  @impl true
  def handle_info({_ref, {:result, id, result}}, %{jobs: jobs} = state) do
    case result do
      {:error, error} ->
        Logger.error("Task [#{id}] failed: #{error}")
        State.add_error(id, error)

      {:ok, result} ->
        # TODO: This save call overrides the progress set by the task
        State.save_task(result)
    end

    jobs = Map.delete(jobs, id)
    {:noreply, %{state | jobs: jobs}, {:continue, :start_jobs}}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _pid, :normal}, state), do: {:noreply, state}

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    Logger.warn("#{inspect(pid)} down: #{reason}")
    # TODO: Delete job?
    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, state) do
    Process.send_after(self(), :tick, @tick_interval)
    {:noreply, state, {:continue, :start_jobs}}
  end

  def start_task(%State{id: id} = state) do
    Logger.debug("Starting task for id #{id}")

    task =
      Task.async(fn ->
        {:result, id, Twiddle.Task.run(state)}
      end)

    {id, task}
  end
end
