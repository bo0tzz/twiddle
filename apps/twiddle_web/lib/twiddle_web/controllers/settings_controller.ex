defmodule TwiddleWeb.SettingsController do
  use TwiddleWeb, :controller
  require Logger

  def index(conn, _params) do
    settings = Twiddle.Settings.get_settings() |> Map.from_struct()
    render(conn, "index.html", settings)
  end

  def update(conn, %{"settings" => settings} = _params) do
    case Twiddle.Settings.put_settings(settings) do
      :ok -> redirect(conn, to: Routes.page_path(TwiddleWeb.Endpoint, :index))
    end
  end
end
