defmodule TwitchAutodlWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(errors, field) do
    Enum.map(Keyword.get_values(errors, field), fn error ->
      content_tag(:span, error, class: "text-error")
    end)
  end
end
