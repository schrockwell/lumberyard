defmodule HamRadio.Cabrillo.Contact do
  defstruct khz: nil,
            mode: nil,
            datetime: nil,
            my_callsign: nil,
            rst_sent: nil,
            exchange_sent: nil,
            callsign: nil,
            rst_received: nil,
            exchange_received: nil,
            errors: []
end
