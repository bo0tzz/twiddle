defmodule TwitchAutodlWeb.PageController do
  use TwitchAutodlWeb, :controller
  require Logger

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def create(conn, _params) do
    # TODO:
    # Validate URL from params
    # Create new download task for URL
    # Redirect to download task page
    render(conn, "index.html")
  end
end
