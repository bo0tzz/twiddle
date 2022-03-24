defmodule TwitchAutodlWeb.PageController do
  use TwitchAutodlWeb, :controller
  require Logger

  def index(conn, _params) do
    render(conn, "index.html", errors: [])
  end

  def create(conn, %{"url" => url}) do
    Logger.info("Got create for url #{url}")

    case TwitchAutodl.download(url) do
      {:ok, id} -> redirect(conn, to: Routes.task_path(TwitchAutodlWeb.Endpoint, :show, id))
      {:error, message} -> render(conn, "index.html", errors: [url: message])
    end
  end
end
