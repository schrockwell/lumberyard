defmodule LumberWeb.PrepareWwsacSubmissionLive do
  use LumberWeb, :live_view

  alias Lumber.Wwsac

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Wwsac.get_wwsac_submission(id) do
      {:ok, sub} ->
        contest = sub.contest
        changeset = Wwsac.prepare_wwsac_submission_changeset(sub)
        other_subs_count = Wwsac.count_other_wwsac_submissions(sub)

        options = %{
          overlay: Wwsac.overlay_options(),
          age_group: Wwsac.age_group_options(),
          power_level: Wwsac.power_level_options()
        }

        {:ok,
         assign(socket,
           contest: contest,
           sub: sub,
           other_subs_count: other_subs_count,
           changeset: changeset,
           options: options
         )}

      :error ->
        # TODO: Do something!!
        {:ok, socket}
    end
  end

  @impl true
  def handle_event("validate", %{"submission" => params}, socket) do
    # IO.inspect(params, label: "validate")
    {:noreply, update_changeset(socket, params)}
  end

  def handle_event("submit", %{"submission" => params}, socket) do
    # IO.inspect(params, label: "submit")
    {:noreply, save(socket, params)}
  end

  def handle_event("cancel", _, socket) do
    Wwsac.cancel_wwsac_submission(socket.assigns.sub)
    {:noreply, redirect(socket, to: Routes.wwsac_submission_path(socket, :index))}
  end

  defp update_changeset(socket, params) do
    changeset =
      socket.assigns.sub
      |> Wwsac.prepare_wwsac_submission_changeset(params)
      |> Map.put(:action, :create)

    assign(socket, changeset: changeset)
  end

  defp save(socket, params) do
    changeset =
      socket.assigns.sub
      |> Wwsac.prepare_wwsac_submission_changeset(params)
      |> Wwsac.submit_wwsac_submission_changeset()

    case Wwsac.submit_wwsac_submission(changeset) do
      {:ok, sub} ->
        assign(socket, sub: sub, changeset: changeset)

      {:error, changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  defp file_format(sub) do
    case Wwsac.guess_submission_format(sub) do
      {:ok, :cabrillo} -> "Cabrillo"
      {:ok, :adif} -> "ADIF"
      :error -> "Unknown"
    end
  end
end
