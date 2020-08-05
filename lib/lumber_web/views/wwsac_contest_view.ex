defmodule LumberWeb.WwsacContestView do
  use LumberWeb, :view

  defp all_empty?(results) do
    Enum.all?(results, fn r -> r.operators == [] end)
  end
end
