defmodule LumberWeb.WwsacLeaderboardView do
  use LumberWeb, :view

  defp empty_categories(leaderboards) do
    Enum.filter(leaderboards, fn lb -> lb.operators == [] end)
  end

  defp all_empty?(leaderboards) do
    Enum.all?(leaderboards, fn lb -> lb.operators == [] end)
  end
end
