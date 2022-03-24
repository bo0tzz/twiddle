defmodule TwitchAutodlWeb.SettingsController do
  use TwitchAutodlWeb, :controller
  require Logger

  def index(conn, _params) do
    settings = TwitchAutodl.Settings.get_settings() |> Map.from_struct()
    render(conn, "index.html", settings)
  end

  def update(conn, %{"settings" => settings} = _params) do
    case TwitchAutodl.Settings.put_settings(settings) do
      :ok -> redirect(conn, to: Routes.page_path(TwitchAutodlWeb.Endpoint, :index))
    end
  end
end
