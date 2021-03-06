defmodule Twiddle.Task.Cleanup do
  alias Twiddle.Task.State

  def run(%State{data: %{working_dir: path}} = state) do
    case File.rm_rf(path) do
      {:ok, _} -> {:ok, state}
      error -> error
    end
  end
end
