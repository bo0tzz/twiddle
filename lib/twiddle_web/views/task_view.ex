defmodule TwiddleWeb.TaskView do
  use TwiddleWeb, :view

  def friendly_name(atom) do
    try do
      Phoenix.Naming.resource_name(atom) |> String.capitalize()
    rescue
      ArgumentError -> Phoenix.Naming.humanize(atom)
    end
  end

  def title(%{data: %{title: t}}), do: t
  def title(%{id: id}), do: id
end
