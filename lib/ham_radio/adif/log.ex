defmodule HamRadio.ADIF.Log do
  defstruct header_text: "", header_fields: %{}, contacts: [], errors: []

  def parse_header_datetime(log, header) do
    case Timex.parse(log.header_fields[header], "{YYYY}-{0M}-{D} {h24}:{m}:{s}") do
      {:ok, time} -> {:ok, DateTime.from_naive!(time, "Etc/UTC")}
      _ -> :error
    end
  end
end
