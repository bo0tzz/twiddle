defmodule TwitchAutodlWeb.TaskController do
  use TwitchAutodlWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", tasks: ["This is definitely a task"])
  end

  def show(conn, %{"id" => id}) do
    {:ok, task} = TwitchAutodl.get_task(id)
    render(conn, "show.html", task: task)
  end
end
