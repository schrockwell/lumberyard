defmodule LumberWeb.Admin.WwsacSubmissionHTML do
  @moduledoc """
  This module contains pages rendered by Admin.WwsacSubmissionController.
  """
  use LumberWeb, :html

  embed_templates "wwsac_submission_html/*"

  attr :changeset, :any, required: true
  attr :action, :string, required: true
  attr :options, :any, required: true

  def submission_form(assigns) do
    ~H"""
    <.form :let={f} for={@changeset} action={@action}>
      <div class="flex">
        <div class="md:w-1/2">
          {hidden_input(f, :contest_id)}

          <.input field={f[:callsign]} type="text" label="Callsign" class="font-mono uppercase" placeholder="MYCALL" />

          <.input field={f[:age_group]} type="select" label="Age Group" options={@options.age_group} />

          <.input field={f[:power_level]} type="select" label="Power Level" options={@options.power_level} />

          <.input field={f[:email]} type="email" label="Email" placeholder="Required" />

          <.input field={f[:send_notifications]} type="checkbox" label="E-mail results of this week's contest" />
        </div>

        <div class="md:w-1/2">
          <.input field={f[:qso_count]} type="text" label="QSO Count" placeholder="Optional" />
          <.input field={f[:qso_points]} type="text" label="QSO Points" placeholder="Optional" />
          <.input field={f[:prefix_count]} type="text" label="Prefixes" placeholder="Optional" />
          <.input field={f[:final_score]} type="text" label="Final Score" placeholder="Required" />
        </div>
      </div>

      <button type="submit" class="btn bg-blue-500 text-white hover:bg-blue-700">
        Save Changes
      </button>
    </.form>
    """
  end
end
