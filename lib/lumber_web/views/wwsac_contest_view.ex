defmodule LumberWeb.WwsacContestView do
  use LumberWeb, :view

  defp empty_categories(results) do
    Enum.filter(results, fn r -> r.operators == [] end)
  end

  defp all_empty?(results) do
    Enum.all?(results, fn r -> r.operators == [] end)
  end
end
