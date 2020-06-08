defmodule HamRadio.Cabrillo do
  alias HamRadio.Cabrillo

  def decode(string) do
    {:ok, io} = StringIO.open(string)

    try do
      io
      |> IO.stream(32)
      |> Cabrillo.Decoder.decode()
    after
      StringIO.close(io)
    end
  end

  def decode_file(filename) do
    filename
    |> File.stream!([], 32)
    |> Cabrillo.Decoder.decode()
  end
end
