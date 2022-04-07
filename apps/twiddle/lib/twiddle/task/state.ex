defmodule Twiddle.Task.State do
  alias Twiddle.Task.State

  defstruct [:id, :data, :options, :next_tasks, :stats, :errors, :progress]

  def new(id, path, options \\ [])

  def new(id, path, options) when is_integer(id),
    do: Integer.to_string(id) |> new(path, options)

  def new(id, path, options) do
    %State{
      id: id,
      data: %{
        path: path
      },
      options: options,
      stats: %{},
      errors: [],
      progress: %{}
    }
  end

  def get_tasks(), do: ConfigServer.get(__MODULE__, &Map.values/1)
  def get_task(id) when is_integer(id), do: Integer.to_string(id) |> get_task()

  def get_task(id) do
    ConfigServer.get(__MODULE__, &Map.fetch(&1, id))
  end

  def save_task(%State{id: id} = task) do
    ConfigServer.update(__MODULE__, &Map.put(&1, id, task))
  end

  def add_error(id, error) do
    ConfigServer.update(
      __MODULE__,
      &update_if_present(&1, id, fn %{errors: errors} = task ->
        %{task | errors: [error | errors]}
      end)
    )
  end

  def set_progress(id, step, progress) do
    ConfigServer.update(
      __MODULE__,
      &update_if_present(&1, id, fn %{progress: progress_map} = task ->
        progress_map = Map.put(progress_map, step, progress)
        %{task | progress: progress_map}
      end)
    )
  end

  defp update_if_present(map, key, update_fn) do
    case Map.fetch(map, key) do
      {:ok, value} -> Map.put(map, key, update_fn.(value))
      :error -> map
    end
  end

  # Turn this into a use ConfigServer?
  def child_spec(arg) do
    options =
      [
        name: __MODULE__,
        path: &Twiddle.Settings.database_file/0,
        default_fn: fn -> %{} end
      ]
      |> Keyword.merge(arg)

    %{
      id: __MODULE__,
      start: {ConfigServer, :start_link, [options]}
    }
  end
end
