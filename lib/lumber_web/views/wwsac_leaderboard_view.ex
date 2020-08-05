defmodule LumberWeb.WwsacLeaderboardView do
  use LumberWeb, :view

  defp all_empty?(leaderboards) do
    Enum.all?(leaderboards, fn lb -> lb.operators == [] end)
  end
end
