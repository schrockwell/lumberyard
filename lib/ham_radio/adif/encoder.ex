defmodule HamRadio.ADIF.Encoder do
  alias HamRadio.ADIF

  @doc """
  Returns {:ok, iolist} or {:error, field, type, value}
  """
  def encode(adif, opts \\ [])

  def encode(%ADIF.Log{} = log, opts) do
    pretty = Keyword.get(opts, :pretty, false)

    with {:ok, header_iolist} <- encode_fields(log.header_fields, pretty),
         {:ok, contacts_iolist} <- encode(log.contacts, opts) do
      if pretty do
        {:ok, ["Generated at #{Timex.now()}\n\n", header_iolist, "<EOH>\n\n", contacts_iolist]}
      else
        {:ok, ["Generated at #{Timex.now()}", header_iolist, "<EOH>", contacts_iolist]}
      end
    end
  end

  def encode(%ADIF.Contact{} = contact, opts) do
    pretty = Keyword.get(opts, :pretty, false)

    with {:ok, iolist} <- encode_fields(contact.fields, pretty) do
      if pretty do
        {:ok, [iolist, "<EOR>\n\n"]}
      else
        {:ok, [iolist, "<EOR>"]}
      end
    end
  end

  def encode(contacts, opts) when is_list(contacts) do
    contact_encodes = Enum.map(contacts, &encode(&1, opts))

    contact_encodes
    |> Enum.find(&match?({:error, _field, _type, _value}, &1))
    |> case do
      nil -> {:ok, Enum.map(contact_encodes, &elem(&1, 1))}
      error -> error
    end
  end

  # Returns {:ok, iolist} or {:error, field, type, value}
  defp encode_fields(fields, pretty) do
    encoded_fields =
      Enum.map(fields, fn {field, value} -> {field, ADIF.Fields.encode(field, value)} end)

    encoded_fields
    |> Enum.find(&match?({_field, {:error, _type, _value}}, &1))
    |> case do
      nil ->
        {
          :ok,
          Enum.map(encoded_fields, fn {field, {:ok, value}} ->
            adif_field(field, value, pretty)
          end)
        }

      {field, {:error, type, value}} ->
        {:error, field, type, value}
    end
  end

  # Returns an iolist
  defp adif_field(field, value, pretty) do
    length = value |> byte_size |> to_string

    if pretty do
      ["<", field, ":", length, ">", value, "\n"]
    else
      ["<", field, ":", length, ">", value]
    end
  end
end
