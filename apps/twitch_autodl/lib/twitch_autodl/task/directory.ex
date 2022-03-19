defmodule TwitchAutodl.Task.Directory do
  alias TwitchAutodl.Task.State

  def run(%State{id: id, data: %{path: path} = data} = state) do
    working_dir = path |> Path.join(".#{id}") |> Path.absname()

    case File.mkdir_p(working_dir) do
      :ok ->
        data = Map.put(data, :working_dir, working_dir)
        {:ok, %{state | data: data}}

      error ->
        error
    end
  end
end
