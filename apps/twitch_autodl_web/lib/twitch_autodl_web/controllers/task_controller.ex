defmodule TwitchAutodlWeb.TaskController do
  use TwitchAutodlWeb, :controller

  def index(conn, _params) do
    tasks = TwitchAutodl.get_tasks()
    render(conn, "index.html", tasks: tasks)
  end

  def show(conn, %{"id" => id}) do
    case TwitchAutodl.get_task(id) do
      {:ok, task} ->
        render(conn, "show.html", task: task)

      :error ->
        conn
        |> put_status(:not_found)
        |> put_view(TwitchAutodlWeb.ErrorView)
        |> render(:"404")
    end
  end
end
