defmodule TwiddleWeb.TaskController do
  use TwiddleWeb, :controller

  def index(conn, _params) do
    tasks = Twiddle.get_tasks()
    render(conn, "index.html", tasks: tasks)
  end

  def show(conn, %{"id" => id}) do
    case Twiddle.get_task(id) do
      {:ok, task} ->
        render(conn, "show.html", task: task)

      :error ->
        conn
        |> put_status(:not_found)
        |> put_view(TwiddleWeb.ErrorView)
        |> render(:"404")
    end
  end
end
