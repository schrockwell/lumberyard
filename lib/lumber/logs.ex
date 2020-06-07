defmodule Lumber.Logs do
  def guess_format(string) do
    cond do
      is_cabrillo?(string) -> {:ok, :cabrillo}
      is_adif?(string) -> {:ok, :adif}
      true -> :error
    end
  end

  defp is_cabrillo?(string) do
    string
    |> String.trim()
    |> String.upcase()
    |> String.starts_with?("START-OF-LOG:")
  end

  defp is_adif?(string) do
    beginning =
      string
      |> String.trim()
      |> String.upcase()

    String.contains?(beginning, "<EOH>") or String.contains?(beginning, "<CALL")
  end
end
