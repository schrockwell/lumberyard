defmodule HamRadio.ADIF do
  alias __MODULE__

  def version, do: Version.parse!("3.0.5")

  def decode(string) do
    {:ok, io} = StringIO.open(string)

    try do
      io
      |> IO.stream(32)
      |> ADIF.Decoder.decode()
    after
      StringIO.close(io)
    end
  end

  def encode(contact_or_log, opts \\ []) do
    ADIF.Encoder.encode(contact_or_log, opts)
  end

  def decode_file(filename) do
    filename
    |> File.stream!([], 32)
    |> ADIF.Decoder.decode()
  end

  def stream_file_contacts(filename) do
    filename
    |> File.stream!([], 32)
    |> ADIF.Decoder.stream_contacts()
  end
end
