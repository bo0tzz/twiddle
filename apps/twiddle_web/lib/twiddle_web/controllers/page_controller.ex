defmodule TwiddleWeb.PageController do
  use TwiddleWeb, :controller
  require Logger

  def index(conn, _params) do
    render(conn, "index.html", errors: [])
  end

  def create(conn, %{"url" => url}) do
    Logger.info("Got create for url #{url}")

    case Twiddle.download(url) do
      {:ok, id} -> redirect(conn, to: Routes.task_path(TwiddleWeb.Endpoint, :show, id))
      {:error, message} -> render(conn, "index.html", errors: [url: message])
    end
  end
end
