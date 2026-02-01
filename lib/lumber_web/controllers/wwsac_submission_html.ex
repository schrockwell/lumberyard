defmodule LumberWeb.WwsacSubmissionHTML do
  @moduledoc """
  This module contains pages rendered by WwsacSubmissionController.
  """
  use LumberWeb, :html

  embed_templates "wwsac_submission_html/*"

  attr :changeset, :any, required: true
  attr :contest, :any, required: true
  attr :conn, :any, required: true

  def upload_form(assigns) do
    ~H"""
    <div class="panel">
      <div class="panel-title">Upload Your Log</div>
      <div class="panel-body p-6">
        <%= if @changeset do %>
          <p class="mb-8">
            Now accepting submissions for {@contest.title}, until {wwsac_submission_before(@contest.submissions_before)}.
          </p>

          <.form :let={f} for={@changeset} action={~p"/wwsac/submit"} multipart>
            {file_input f, :file, class: "mr-4 cursor-pointer outline-none"}
            {submit "Continue", class: "btn btn-blue"}
          </.form>

          <%= if @changeset.action != nil && @changeset.errors != [] do %>
            <div class="text-red-600 mt-4">
              <p class="mb-4">The following problems were encountered when reading this log file:</p>

              <ul class="bulleted">
                <%= for {_field, {message, _meta}} <- @changeset.errors do %>
                  <li>{message}</li>
                <% end %>
              </ul>
            </div>
          <% end %>
        <% else %>
          Submissions are not being accepted for the next WWSAC.
        <% end %>
      </div>
    </div>
    """
  end
end
