defmodule Lumber.Format do
  @doc """
  Add "," thousands delimiters to an integer.
  """
  def delimit(int) when is_integer(int) do
    reversed =
      int
      |> Integer.to_string()
      |> String.reverse()

    Regex.scan(~r/\d{3}|\d{2}\Z|\d{1}\Z/, reversed)
    |> List.flatten()
    |> Enum.map(&String.reverse/1)
    |> Enum.reverse()
    |> Enum.join(",")
  end

  def long_date(datetime) do
    Timex.format!(datetime, "{Mfull} {D}, {YYYY}")
  end

  def wwsac_submission_before(datetime) do
    "#{long_date(datetime)} at #{utc_time(datetime)}Z"
  end

  def utc_time(datetime) do
    Timex.format!(datetime, "{h24}{m}")
  end
end
