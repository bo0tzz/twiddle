defmodule TwitchAutodlWeb.PageController do
  use TwitchAutodlWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
