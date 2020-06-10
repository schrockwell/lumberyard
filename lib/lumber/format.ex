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
end
