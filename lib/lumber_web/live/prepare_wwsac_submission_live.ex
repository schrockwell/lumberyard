defmodule LumberWeb.PrepareWwsacSubmissionLive do
  use LumberWeb, :live_view

  alias Lumber.Contests
  alias Lumber.Wwsac

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Contests.get_wwsac_submission(id) do
      {:ok, sub} ->
        contest = sub.contest
        changeset = Contests.prepare_wwsac_submission_changeset(sub)
        wwsac_log = Wwsac.get_wwsac_log(sub.file_contents)

        options = %{
          overlay: Contests.overlay_options(),
          age_group: Contests.age_group_options(),
          power_level: Contests.power_level_options()
        }

        {:ok,
         assign(socket,
           contest: contest,
           sub: sub,
           changeset: changeset,
           options: options,
           wwsac_log: wwsac_log
         )}

      :error ->
        # TODO: Do something!!
        {:ok, socket}
    end
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
      |> Contests.prepare_wwsac_submission_changeset(params)
      |> Map.put(:action, :create)

    assign(socket, changeset: changeset)
  end

  defp save(socket, params) do
    changeset =
      socket.assigns.sub
      |> Contests.prepare_wwsac_submission_changeset(params)
      |> Contests.submit_wwsac_submission_changeset()

    case Contests.save_wwsac_submission(changeset) do
      {:ok, sub} ->
        assign(socket, sub: sub, changeset: changeset)

      {:error, changeset} ->
        assign(socket, changeset: changeset)
    end
  end

  defp file_format(sub) do
    case Contests.guess_submission_format(sub) do
      {:ok, :cabrillo} -> "Cabrillo"
      {:ok, :adif} -> "ADIF"
      :error -> "Unknown"
    end
  end
end
