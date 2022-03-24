defmodule TwitchAutodl.Settings do
  defstruct download_folder: "download/", database_file: "state.db"

  def get_settings(), do: ConfigServer.get(__MODULE__, & &1)
  def database_file(), do: get_setting(:database_file)
  def download_folder(), do: get_setting(:download_folder)

  # TODO: Singular update functions
  def put_settings(%Settings{} = settings), do: ConfigServer.update(__MODULE__, fn _ -> settings end)

  defp get_setting(setting), do: ConfigServer.get(__MODULE__, &Map.get(&1, setting))

  def child_spec(_args) do
    options = [
      name: __MODULE__,
      # TODO: From env
      path: "config.yaml",
      default_fn: fn -> %TwitchAutodl.Settings{} end,
      storage: ConfigServer.Storage.Yaml,
      save_hook: &Map.from_struct/1,
      load_hook: &Maptu.struct!(TwitchAutodl.Settings, &1)
    ]

    %{
      id: __MODULE__,
      start: {ConfigServer, :start_link, [options]}
    }
  end
end
