defmodule HamRadio.Cabrillo.Decoder do
  alias HamRadio.Cabrillo.Parser
  alias HamRadio.Cabrillo.Log
  alias HamRadio.Cabrillo.Contact

  def decode(stream) do
    initial_acc = %Log{}

    stream
    |> Parser.stream()
    |> Enum.reduce(initial_acc, &reducer/2)
  end

  defp reducer({"QSO", string}, log) do
    # "7195 PH 5/26/2020 0145 KW8N 59 OM KD2TJU 59 OM"

    contact =
      string
      |> String.split()
      |> Enum.with_index()
      |> Enum.reduce(%Contact{}, &parse_line/2)

    %{log | contacts: log.contacts ++ [contact]}
  end

  defp reducer({"END-OF-LOG", _}, log) do
    log
  end

  defp reducer({key, value}, log) do
    header_fields = Map.update(log.header_fields, key, value, fn v -> "#{v}\n#{value}" end)
    %{log | header_fields: header_fields}
  end

  defp parse_us_date(string) do
    with {:error, _} <- Timex.parse(string, "{0M}/{0D}/{YYYY}"),
         {:error, _} <- Timex.parse(string, "{M}/{0D}/{YYYY}"),
         {:error, _} <- Timex.parse(string, "{0M}/{D}/{YYYY}"),
         {:error, _} <- Timex.parse(string, "{M}/{D}/{YYYY}") do
      {:error, "invalid US date format"}
    else
      {:ok, datetime} ->
        {:ok, datetime}
    end
  end

  defp parse_iso_date(string) do
    Timex.parse(string, "{YYYY}-{0M}-{0D}")
  end

  defp parse_line({khz_string, 0}, contact) do
    %{contact | khz: String.to_integer(khz_string)}
  end

  defp parse_line({mode, 1}, contact) do
    %{contact | mode: mode}
  end

  defp parse_line({date_string, 2}, contact) do
    with {:error, _reason} <- parse_iso_date(date_string),
         {:error, _reason} <- parse_us_date(date_string) do
      %{contact | errors: ["invalid date format" | contact.errors]}
    else
      {:ok, datetime} ->
        %{contact | datetime: datetime}
    end
  end

  defp parse_line({zulu, 3}, %{datetime: %NaiveDateTime{} = datetime} = contact) do
    hours = zulu |> String.slice(0..1) |> String.to_integer()
    minutes = zulu |> String.slice(2..3) |> String.to_integer()

    new_datetime =
      datetime
      |> DateTime.from_naive!("Etc/UTC")
      |> Timex.shift(hours: hours, minutes: minutes)

    %{contact | datetime: new_datetime}
  end

  defp parse_line({my_callsign, 4}, contact) do
    %{contact | my_callsign: my_callsign}
  end

  defp parse_line({rst_sent, 5}, contact) do
    %{contact | rst_sent: rst_sent}
  end

  defp parse_line({exchange_sent, 6}, contact) do
    %{contact | exchange_sent: exchange_sent}
  end

  defp parse_line({callsign, 7}, contact) do
    %{contact | callsign: callsign}
  end

  defp parse_line({rst_received, 8}, contact) do
    %{contact | rst_received: rst_received}
  end

  defp parse_line({exchange_received, 9}, contact) do
    %{contact | exchange_received: exchange_received}
  end

  defp parse_line({_, index}, contact) when index > 9 do
    if Enum.find(contact.errors, fn error -> error == "has too many fields" end) do
      contact
    else
      %{contact | errors: ["has too many fields" | contact.errors]}
    end
  end

  defp parse_line(_, contact) do
    contact
  end
end
