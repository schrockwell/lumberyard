defmodule Lumber.Wwsac.Log do
  defstruct errors: [],
            contacts: [],
            total_contact_points: 0,
            total_prefixes: 0,
            final_score: 0

  alias HamRadio.ADIF
  alias HamRadio.Cabrillo

  alias Lumber.Wwsac
  alias Lumber.Logs

  def from_file_contents(file_contents) do
    case Logs.guess_format(file_contents) do
      {:ok, :adif} ->
        file_contents
        |> ADIF.decode()
        |> to_wwsac_log()
        |> update_contact_scores()
        |> update_log_scores()

      {:ok, :cabrillo} ->
        file_contents
        |> Cabrillo.decode()
        |> to_wwsac_log()
        |> update_contact_scores()
        |> update_log_scores()

      _ ->
        nil
    end
  end

  defp to_wwsac_log(%ADIF.Log{} = log) do
    wwsac_contacts =
      for adif_contact <- log.contacts do
        %Wwsac.Contact{
          khz: adif_contact.fields["FREQ"] * 1000,
          datetime: adif_datetime(adif_contact),
          callsign: adif_contact.fields["CALL"],
          my_callsign: adif_contact.fields["STATION_CALLSIGN"] || adif_contact.fields["OPERATOR"],
          exchange_received: adif_contact.fields["SECTION"],
          errors: adif_contact.errors,
          prefix: nil,
          points: 0,
          multipliers: 0,
          tags: []
        }
      end

    %Wwsac.Log{
      errors: log.errors,
      contacts: wwsac_contacts
    }
  end

  defp to_wwsac_log(%Cabrillo.Log{} = log) do
    wwsac_contacts =
      for cabrillo_contact <- log.contacts do
        %Wwsac.Contact{
          khz: cabrillo_contact.khz,
          datetime: cabrillo_contact.datetime,
          callsign: cabrillo_contact.callsign,
          my_callsign: cabrillo_contact.my_callsign,
          exchange_received: cabrillo_contact.exchange_received,
          errors: cabrillo_contact.errors,
          prefix: nil,
          points: 0,
          multipliers: 0,
          tags: []
        }
      end

    %Wwsac.Log{
      errors: log.errors,
      contacts: wwsac_contacts
    }
  end

  defp adif_datetime(adif_contact) do
    date = adif_contact.fields["QSO_DATE"]
    time = adif_contact.fields["TIME_ON"]

    date
    |> Timex.to_datetime()
    |> Timex.shift(hours: time.hour, minutes: time.minute, seconds: time.second)
  end

  defp update_contact_scores(wwsac_log) do
    acc = %{
      prefixes: MapSet.new(),
      contacts: []
    }

    acc =
      Enum.reduce(wwsac_log.contacts, acc, fn contact, acc ->
        qso_points = exchange_points(contact.exchange_received)
        prefix = callsign_prefix(contact.callsign)
        mults = if MapSet.member?(acc.prefixes, prefix), do: 0, else: 1

        contact = %{
          contact
          | points: qso_points,
            multipliers: mults,
            prefix: prefix
        }

        %{
          prefixes: MapSet.put(acc.prefixes, prefix),
          contacts: [contact | acc.contacts]
        }
      end)

    %{wwsac_log | contacts: Enum.reverse(acc.contacts)}
  end

  defp exchange_points("OM"), do: 1
  defp exchange_points("YL"), do: 5
  defp exchange_points("Y"), do: 10
  defp exchange_points("YYL"), do: 15
  defp exchange_points(_), do: 0

  defp callsign_prefix(callsign) do
    Wwsac.Prefixes.find(callsign)
  end

  defp update_log_scores(wwsac_log) do
    total_contact_points = wwsac_log.contacts |> Enum.map(& &1.points) |> Enum.sum()
    total_prefixes = wwsac_log.contacts |> Enum.map(& &1.multipliers) |> Enum.sum()

    %{
      wwsac_log
      | total_contact_points: total_contact_points,
        total_prefixes: total_prefixes,
        final_score: total_contact_points * total_prefixes
    }
  end
end
