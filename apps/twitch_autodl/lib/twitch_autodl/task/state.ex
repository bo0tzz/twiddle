defmodule TwitchAutodl.Task.State do
  alias TwitchAutodl.Task.State

  defstruct [:id, :data, :options, :next_tasks, :stats]

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
      stats: %{}
    }
  end
end
