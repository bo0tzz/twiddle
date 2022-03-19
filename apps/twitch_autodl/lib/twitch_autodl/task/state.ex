defmodule TwitchAutodl.Task.State do
  alias TwitchAutodl.Task.State

  defstruct [:id, :data, :next_tasks, :stats]

  def new(id, path) when is_integer(id), do: Integer.to_string(id) |> new(path)

  def new(id, path) do
    %State{
      id: id,
      data: %{
        path: path
      },
      stats: %{}
    }
  end
end
