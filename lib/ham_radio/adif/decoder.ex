defmodule HamRadio.ADIF.Decoder do
  alias HamRadio.ADIF.{Contact, Log, Fields, Parser}

  @doc """
  Loads a complete log into memory
  """
  def decode(stream) do
    initial_acc = {:header, %Contact{}, %Log{}}

    stream
    |> Parser.stream()
    |> Enum.reduce(initial_acc, &reducer/2)
    |> elem(2)
    |> reverse_lists
  end

  @doc """
  Streams a list of `ADIF.Contact` structs only
  """
  def stream_contacts(stream) do
    initial_acc = {:header, %Contact{}}

    stream
    |> Parser.stream()
    |> Stream.transform(initial_acc, &stream_reducer/2)
  end

  # Accumulator spec: {:header | :contact, %Contact{}, %Log{}}

  # Header fields and text
  defp reducer(string, {:header, contact, log}) when is_binary(string) do
    {:header, contact, %{log | header_text: log.header_text <> string}}
  end

  defp reducer({"EOH", nil}, {:header, contact, log}) do
    {:contact, contact, log}
  end

  defp reducer({field, value}, {:header, contact, %{header_text: ""} = log}) do
    # "If the first character in an ADI file is <, it contains no Header."
    reducer({field, value}, {:contact, contact, log})
  end

  defp reducer({field, value}, {:header, contact, log}) do
    {:header, contact, decode_header_field(log, field, value)}
  end

  # Contact fields
  defp reducer(string, {:contact, contact, log}) when is_binary(string) do
    {:contact, contact, log}
  end

  defp reducer({"EOR", nil}, {:contact, contact, log}) do
    {:contact, %Contact{}, add_contact(log, contact)}
  end

  defp reducer({field, value}, {:contact, contact, log}) do
    {:contact, decode_contact_field(contact, field, value), log}
  end

  # Stream accumulator spec: {:header | :contact, %Contact{}}

  # Streaming header fields and text (all ignored!)
  defp stream_reducer({"EOH", nil}, {:header, contact}) do
    {[], {:contact, contact}}
  end

  defp stream_reducer(_any, {:header, contact}) do
    {[], {:header, contact}}
  end

  # Streaming contact fields
  defp stream_reducer(string, {:contact, contact}) when is_binary(string) do
    {[], {:contact, contact}}
  end

  defp stream_reducer({"EOR", nil}, {:contact, contact}) do
    {[contact], {:contact, %Contact{}}}
  end

  defp stream_reducer({field, value}, {:contact, contact}) do
    {[], {:contact, decode_contact_field(contact, field, value)}}
  end

  # Common functions

  # Type coercion for fields
  defp decode_header_field(%Log{} = log, field, value) do
    case Fields.decode(field, value) do
      {:ok, value} ->
        %{log | header_fields: Map.put(log.header_fields, field, value)}

      {:error, :unknown} ->
        %{log | header_fields: Map.put(log.header_fields, field, value)}

      :error ->
        add_error(log, "Could not decode #{field} value '#{value}'")
    end
  end

  defp decode_contact_field(%Contact{} = contact, field, value) do
    case Fields.decode(field, value) do
      {:ok, value} ->
        %{contact | fields: Map.put(contact.fields, field, value)}

      {:error, :unknown} ->
        %{contact | fields: Map.put(contact.fields, field, value)}

      :error ->
        add_error(contact, "Could not decode #{field} value '#{value}'")
    end
  end

  # Managing list types
  defp add_contact(%Log{contacts: contacts} = log, contact) do
    contact = Map.update!(contact, :errors, &Enum.reverse/1)
    %{log | contacts: [contact | contacts]}
  end

  defp add_error(%{errors: errors} = map, error) do
    %{map | errors: [error | errors]}
  end

  defp reverse_lists(%Log{} = log) do
    log
    |> Map.update!(:contacts, &Enum.reverse/1)
    |> Map.update!(:errors, &Enum.reverse/1)
  end
end
