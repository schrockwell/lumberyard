defmodule HamRadio.ADIF.Parser do
  @doc """
  Parses a file stream into a stream of strings and tuples, where:

    - A string indicates a portion of raw text that is not part of a tag or
      its data
    - A `{tag_name, tag_data}` tuple indicates a tag. The `tag_name` is an
      uppercase string, and the `tag_data` is either a string, or `nil` if the
      tag has no data.

  There will always be a trailing string token, which may be an empty string.
  """
  def stream(file_stream) do
    Stream.transform(file_stream, "", fn chunk, rest ->
      [new_rest | tokens] = parse(rest <> chunk)
      {Enum.reverse(tokens), new_rest}
    end)
  end

  # Parses an ADI-formatted string into a REVERSED token list
  defp parse(string) do
    parse("", string, [])
  end

  # Found a tag
  defp parse(before, "<" <> _ = string, tokens) do
    case parse_tag(string) do
      nil ->
        # Tag incomplete, so must be the end of the line
        parse(before <> string, "", tokens)

      {new_tag, rest} ->
        # Tag complete, so keep parsing. Only append non-empty text
        if before == "" do
          parse("", rest, [new_tag | tokens])
        else
          parse("", rest, [new_tag, before | tokens])
        end
    end
  end

  # Unexpected text
  defp parse(before, <<char::binary-size(1), rest::binary>>, tokens) do
    parse(before <> char, rest, tokens)
  end

  # End of the line
  defp parse(before, "", tokens) do
    [before | tokens]
  end

  # Accepts a string beginning with "<" and attempts to parse a tag.
  #
  # Returns: 
  #   - `{{tag_name, nil}, rest}` if the tag is empty
  #   - `{{tag_name, tag_data}, rest}` if the tag has data
  #   - `nil` if the string if the tag definition is incomplete, or the string
  #     is too short to contain the tag's data

  # Split method - fastest with 32-byte chunks

  def parse_tag("<" <> _ = string) do
    case String.split(string, ">", parts: 2) do
      [_rest] ->
        nil

      ["<" <> name, rest] ->
        case String.split(name, ":") do
          [name] ->
            {{normalize_tag(name), nil}, rest}

          [name, length | _] ->
            length = String.to_integer(length)

            if length > String.length(rest) do
              nil
            else
              {data, rest} = String.split_at(rest, length)
              {{normalize_tag(name), data}, rest}
            end
        end
    end
  end

  # Recursion method

  # def parse_tag("<" <> rest = string) do
  #   parse_tag(rest, "", "", :name)
  # end

  # defp parse_tag("", _, _, _), do: nil

  # defp parse_tag(">" <> rest, name, "", :name) do
  #   {{normalize_tag(name), nil}, rest}
  # end
  # defp parse_tag(<<":", rest :: binary>>, name, "", :name) do
  #   parse_tag(rest, name, "", :length)
  # end
  # defp parse_tag(<<char :: binary-size(1), rest :: binary>>, name, "", :name) do
  #   parse_tag(rest, name <> char, "", :name)
  # end

  # defp parse_tag(<<">", rest :: binary>>, name, length, :length) do
  #   length = String.to_integer(length)
  #   if length > String.length(rest) do
  #     nil
  #   else
  #     {data, rest} = String.split_at(rest, length)
  #     {{normalize_tag(name), data}, rest}
  #   end
  # end
  # defp parse_tag(<<char :: binary-size(1), rest :: binary>>, name, length, :length) do
  #   parse_tag(rest, name, length <> char, :length)
  # end

  # Split method

  # def parse_tag(string) do
  #   parse_tag("", string)
  # end
  # defp parse_tag("", ""), do: nil
  # defp parse_tag("", "<" <> rest) do
  #   parse_tag("", rest)
  # end
  # defp parse_tag(name, ">" <> rest) do
  #   case String.split(name, ":") do
  #     [name] -> 
  #       {{normalize_tag(name), nil}, rest}
  #     [name, length | _] -> 
  #       length = String.to_integer(length)
  #       if length > String.length(rest) do
  #         nil
  #       else
  #         {data, rest} = String.split_at(rest, length)
  #         {{normalize_tag(name), data}, rest}
  #       end
  #   end
  # end
  # defp parse_tag(_name, "") do
  #   nil
  # end
  # defp parse_tag(name, <<char :: binary-size(1), rest :: binary>>) do
  #   parse_tag(name <> char, rest)
  # end

  defp normalize_tag(name), do: String.upcase(name)
end
