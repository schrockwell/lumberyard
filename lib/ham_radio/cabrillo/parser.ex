defmodule HamRadio.Cabrillo.Parser do
  @doc """
  Takes in a file stream and generates a file stream that is a list of two-ples,
  where the first element is the line "type" string, and the second element is the
  line contents string.

  Any whitespace is replaced with plain spaces.

  Example output:

      [
        {"START-OF-LOG", "2.0"},
        {"ARRL-SECTION", "OH"},
        {"CALLSIGN", "KW8N"},
        {"CLUB", "None"},
        {"CONTEST", "WWSAC"},
        {"CATEGORY", "SINGLE-OP HIGH SSB"},
        {"CLAIMED-SCORE", ""},
        {"OPERATORS", "KW8N"},
        {"NAME", "Bob Hayes"},
        {"ADDRESS", "9192 Bender Road"},
        {"ADDRESS", "North Ridgeville, OH 44309"},
        {"ADDRESS", "USA"},
        {"CREATED-BY", "Bob Logger 1.0"},
        {"QSO", "7205 PH 5/26/2020 0119 KW8N 59 OM N0JSD 59 Y"},
        {"QSO", "7190 PH 5/26/2020 0120 KW8N 59 OM AA4LS 59 Y"},
        {"QSO", "7185 PH 5/26/2020 0120 KW8N 59 OM KM4SII 59 Y"},
        {"QSO", "7182 PH 5/26/2020 0121 KW8N 59 OM W0AAE 59 Y"},
        ...,
        {"END-OF-LOG", ""}
      ]
  """

  def stream(file_stream) do
    file_stream
    |> to_word_stream()
    |> to_token_stream()
  end

  defp to_word_stream(file_stream) do
    Stream.transform(file_stream, "", fn chunk, rest ->
      case String.split(rest <> chunk, ~r/\s/, trim: false) do
        [unfinished] ->
          {[], unfinished}

        list ->
          finished_words =
            list
            |> Enum.slice(0..-2)
            |> Enum.reject(&(&1 == ""))

          rest = List.last(list)
          {finished_words, rest}
      end
    end)
  end

  defp to_token_stream(word_stream) do
    Stream.transform(word_stream, {nil, []}, &transform_word/2)
  end

  # Special case
  defp transform_word("END-OF-LOG:", _) do
    {[{"END-OF-LOG", ""}], {nil, []}}
  end

  # Set the tag if we're looking for one
  defp transform_word(word, {nil, []} = acc) do
    if String.ends_with?(word, ":") do
      word = String.trim_trailing(word, ":")
      {[], {word, []}}
    else
      {[], acc}
    end
  end

  defp transform_word(word, {key, words}) do
    if String.ends_with?(word, ":") do
      # We're done here!
      string = words |> Enum.reverse() |> Enum.join(" ")

      word = String.trim_trailing(word, ":")
      {[{key, string}], {word, []}}
    else
      {[], {key, [word | words]}}
    end
  end
end
