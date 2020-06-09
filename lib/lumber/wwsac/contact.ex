defmodule Lumber.Wwsac.Contact do
  defstruct khz: nil,
            datetime: nil,
            callsign: nil,
            my_callsign: nil,
            exchange_received: nil,
            prefix: nil,
            points: 0,
            multipliers: 0,
            errors: [],
            tags: []
end
