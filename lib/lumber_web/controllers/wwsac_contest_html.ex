defmodule LumberWeb.WwsacContestHTML do
  @moduledoc """
  This module contains pages rendered by WwsacContestController.
  """
  use LumberWeb, :html

  embed_templates "wwsac_contest_html/*"

  defp all_empty?(results) do
    Enum.all?(results, fn r -> r.operators == [] end)
  end

  attr :result, :any, required: true
  attr :my_callsign, :string, default: nil
  attr :conn, :any, required: true

  def result_panel(assigns) do
    ~H"""
    <%= if @result.operators != [] do %>
      <div class="panel w-full md:w-1/2 lg:w-1/3 mb-8 md:mb-16 flex flex-col">
        <div class="panel-title">
          {@result.category.title}
        </div>

        <div class="panel-body flex-grow">
          <table class="w-full my-2 text-gray-800">
            <thead>
              <tr class="font-medium text-sm text-gray-500">
                <th class="py-1 pl-4 text-left"></th>
                <th class="py-1 text-right">QSOs</th>
                <th class="py-1 text-right">Pts</th>
                <th class="py-1 text-right">Pfx</th>
                <th class="py-1 pr-4 text-right">Score</th>
              </tr>
            </thead>

            <tbody>
              <%= for {operator, place} <- Enum.with_index(@result.operators, 1) do %>
                <tr class={if @my_callsign == operator.callsign, do: "bg-yellow-200"}>
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
                      <span class="inline-block text-gray-500 w-10 text-center text-sm font-medium">{place}</span>
                    <% end %>

                    <span class="font-medium tracking-wide">
                      {operator.callsign}
                    </span>
                  </td>
                  <td class="py-1 text-right">{if operator.qso_count, do: delimit(@conn, operator.qso_count), else: "–"}</td>
                  <td class="py-1 text-right">{if operator.qso_points, do: delimit(@conn, operator.qso_points), else: "–"}</td>
                  <td class="py-1 text-right">{if operator.prefix_count, do: delimit(@conn, operator.prefix_count), else: "–"}</td>
                  <td class="py-1 pr-4 text-right">{delimit(@conn, operator.final_score)}</td>
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
