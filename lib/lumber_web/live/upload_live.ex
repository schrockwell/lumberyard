defmodule LumberWeb.UploadLive do
  use LumberWeb, :live_view

  alias Lumber.Contests

  @impl true
  def mount(_params, _session, socket) do
    contest = Contests.get_next_wwsac_contest()
    sub = Contests.build_wwsac_submission()
    changeset = Contests.new_wwsac_submission_changeset(sub)

    options = %{
      overlay: Contests.overlay_options(),
      age_group: Contests.age_group_options(),
      power_level: Contests.power_level_options()
    }

    {:ok, assign(socket, contest: contest, sub: sub, changeset: changeset, options: options)}
  end

  @impl true
  def handle_event("validate", %{"wwsac_submission" => params}, socket) do
    # IO.inspect(params, label: "validate")
    {:noreply, update_changeset(socket, params)}
  end

  def handle_event("submit", %{"wwsac_submission" => params}, socket) do
    # IO.inspect(params, label: "submit")
    {:noreply, save(socket, params)}
  end

  defp update_changeset(socket, params) do
    changeset =
      socket.assigns.sub
      |> Contests.new_wwsac_submission_changeset(params)
      |> Map.put(:action, :create)

    assign(socket, changeset: changeset)
  end

  defp save(socket, params) do
    changeset = Contests.new_wwsac_submission_changeset(socket.assigns.sub, params)

    case Contests.save_wwsac_submission(changeset) do
      {:ok, sub} ->
        assign(socket, sub: sub, changeset: changeset)

      {:error, changeset} ->
        assign(socket, changeset: changeset)
    end
  end
end
