defmodule LumberWeb.WwsacLeaderboardHTML do
  @moduledoc """
  This module contains pages rendered by WwsacLeaderboardController.
  """
  use LumberWeb, :html

  embed_templates "wwsac_leaderboard_html/*"

  defp all_empty?(leaderboards) do
    Enum.all?(leaderboards, fn lb -> lb.operators == [] end)
  end

  attr :leaderboard, :any, required: true
  attr :my_callsign, :string, default: nil
  attr :conn, :any, required: true

  def leaderboard_panel(assigns) do
    ~H"""
    <%= if @leaderboard.operators != [] do %>
      <div class="panel w-full md:w-1/2 lg:w-1/3 mb-16 flex flex-col">
        <div class="panel-title">
          {@leaderboard.category.title}
        </div>

        <div class="flex-grow sm:rounded shadow -mx-4 sm:mx-0 bg-white">
          <table class="w-full my-2 text-gray-900">
            <thead>
              <tr class="font-medium text-sm text-gray-500">
                <th class="py-1 text-left pl-4"></th>
                <th class="py-1 text-right">Entries</th>
                <th class="py-1 text-right">QSOs</th>
                <th class="py-1 text-right pr-4">Score</th>
              </tr>
            </thead>

            <tbody>
              <%= for {operator, place} <- Enum.with_index(@leaderboard.operators, 1) do %>
                <tr class={if @my_callsign == operator.callsign, do: "bg-yellow-200", else: "hover:bg-gray-200"}>
                  <td class="pl-1 py-1">
                    <%= if place == 1 do %>
                      <span class="inline-block w-10 text-center">🥇</span>
                    <% end %>
                    <%= if place == 2 do %>
                      <span class="inline-block w-10 text-center">🥈</span>
                    <% end %>
                    <%= if place == 3 do %>
                      <span class="inline-block w-10 text-center">🥉</span>
                    <% end %>

                    <%= if place > 3 do %>
                      <span class="inline-block text-gray-500 w-10 text-sm text-center font-medium">{place}</span>
                    <% end %>

                    <span class="font-medium tracking-wide">{operator.callsign}</span>
                  </td>
                  <td class="py-1 text-right">{delimit(@conn, operator.count)}</td>
                  <td class="py-1 text-right">{delimit(@conn, operator.qsos)}</td>
                  <td class="py-1 text-right pr-4">{delimit(@conn, operator.points)}</td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    <% end %>
    """
  end
end
