defmodule Twiddle.Settings do
  defstruct download_folder: "download/", database_file: "state.db", extract_subtitles: false

  def get_settings(), do: ConfigServer.get(__MODULE__, & &1)
  def database_file(), do: get_setting(:database_file)
  def download_folder(), do: get_setting(:download_folder)
  def extract_subtitles(), do: get_setting(:extract_subtitles)

  # TODO: Singular update functions?
  def put_settings(%Twiddle.Settings{} = settings),
    do: ConfigServer.update(__MODULE__, fn _ -> settings end)

  def put_settings(map) do
    with {:ok, struct} <- Maptu.strict_struct(__MODULE__, map) do
      extract_subtitles =
        case struct.extract_subtitles do
          "true" -> true
          "false" -> false
          val when is_boolean(val) -> val
          invalid -> raise ArgumentError, message: "Not a boolean: #{invalid}"
        end

      %{struct | extract_subtitles: extract_subtitles}
      |> put_settings()
    end
  end

  defp get_setting(setting), do: ConfigServer.get(__MODULE__, &Map.get(&1, setting))

  def child_spec(_args) do
    options = [
      name: __MODULE__,
      # TODO: From env
      path: Application.fetch_env!(:twiddle, :config_file),
      default_fn: fn -> %Twiddle.Settings{} end,
      storage: ConfigServer.Storage.Yaml,
      save_hook: &Map.from_struct/1,
      load_hook: &Maptu.struct!(__MODULE__, &1)
    ]

    %{
      id: __MODULE__,
      start: {ConfigServer, :start_link, [options]}
    }
  end
end
