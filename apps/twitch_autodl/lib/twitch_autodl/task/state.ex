defmodule TwitchAutodl.Task.State do
  alias TwitchAutodl.Task.State

  defstruct [:id, :data, :options, :next_tasks, :stats, :errors]

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
      errors: []
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
    ConfigServer.update(__MODULE__, fn map ->
      case Map.fetch(map, id) do
        {:ok, %{errors: errors} = task} -> Map.put(map, id, %{task | errors: [error | errors]})
        :error -> map
      end
    end)
  end

  # Turn this into a use ConfigServer?
  def child_spec(arg) do
    options =
      [
        name: __MODULE__,
        path: &TwitchAutodl.Settings.database_file/0,
        default_fn: fn -> %{} end
      ]
      |> Keyword.merge(arg)

    %{
      id: __MODULE__,
      start: {ConfigServer, :start_link, [options]}
    }
  end
end
