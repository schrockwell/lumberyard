defmodule HamRadio.ADIF.Fields do
  @field_types %{
    "ADDRESS" => :string,
    "ADDRESS_INTL" => :string,
    "AGE" => :integer,
    "A_INDEX" => :integer,
    "ANT_AZ" => :float,
    "ANT_EL" => :float,
    "ANT_PATH" => {:enum, :ant_path},
    "ARRL_SECT" => {:enum, :arrl_section},
    "AWARD_SUBMITTED" => {:list, {:enum, :award}},
    "AWARD_GRANTED" => {:list, {:enum, :award}},
    "BAND" => {:enum, :band},
    "BAND_RX" => {:enum, :band},
    "CALL" => :string,
    "CHECK" => :string,
    "CLASS" => :string,
    "CLUBLOG_QSO_UPLOAD_DATE" => :date,
    "CLUBLOG_QSO_UPLOAD_STATUS" => {:enum, :qso_upload_status},
    "CNTY" => {:enum, :county},
    "COMMENT" => :string,
    "COMMENT_INTL" => :string,
    "CONT" => {:enum, :continent},
    "CONTACTED_OP" => :string,
    "CONTEST_ID" => :string,
    "COUNTRY" => :string,
    "COUNTRY_INTL" => :string,
    "CQZ" => :integer,
    "CREDIT_SUBMITTED" => {:list, {:enum, :credit}},
    "CREDIT_GRANTED" => {:list, {:enum, :credit}},
    "DISTANCE" => :float,
    "DXCC" => :integer,
    "EMAIL" => :string,
    "EQ_CALL" => :string,
    "EQSL_QSLRDATE" => :date,
    "EQSL_QSLSDATE" => :date,
    "EQSL_QSL_RCVD" => {:enum, :qsl_received},
    "EQSL_QSL_SENT" => {:enum, :qsl_sent},
    "FISTS" => :string,
    "FISTS_CC" => :string,
    "FORCE_INIT" => :boolean,
    "FREQ" => :float,
    "FREQ_RX" => :float,
    "GRIDSQUARE" => :grid,
    "GUEST_OP" => :string,
    "HRDLOG_QSO_UPLOAD_DATE" => :date,
    "HRDLOG_QSO_UPLOAD_STATUS" => {:enum, :qso_upload_status},
    "IOTA" => :string,
    "IOTA_ISLAND_ID" => :string,
    "ITUZ" => :integer,
    "K_INDEX" => :integer,
    "LAT" => {:coordinate, :latitude},
    "LON" => {:coordinate, :longitude},
    "LOTW_QSLRDATE" => :date,
    "LOTW_QSLSDATE" => :date,
    "LOTW_QSL_RCVD" => {:enum, :qsl_received},
    "LOTW_QSL_SENT" => {:enum, :qsl_sent},
    "MAX_BURSTS" => :float,
    "MODE" => {:enum, :mode},
    "MS_SHOWER" => :string,
    "MY_CITY" => :string,
    "MY_CITY_INTL" => :string,
    "MY_CNTY" => {:enum, :county},
    "MY_COUNTRY" => :string,
    "MY_COUNTRY_INTL" => :string,
    "MY_CQ_ZONE" => :integer,
    "MY_DXCC" => :integer,
    "MY_FISTS" => :string,
    "MY_GRIDSQUARE" => :grid,
    "MY_IOTA" => :string,
    "MY_IOTA_ISLAND_ID" => :string,
    "MY_ITU_ZONE" => :string,
    "MY_LAT" => {:coordinate, :latitude},
    "MY_LON" => {:coordinate, :longitude},
    "MY_NAME" => :string,
    "MY_NAME_INTL" => :string,
    "MY_POSTAL_CODE" => :string,
    "MY_POSTAL_CODE_INTL" => :string,
    "MY_RIG" => :string,
    "MY_RIG_INTL" => :string,
    "MY_SIG" => :string,
    "MY_SIG_INTL" => :string,
    "MY_SIG_INFO" => :string,
    "MY_SIG_INFO_INTL" => :string,
    "MY_SOTA_REF" => :string,
    "MY_STATE" => {:enum, :state},
    "MY_STREET" => :string,
    "MY_STREET_INTL" => :string,
    "MY_USACA_COUNTIES" => {:list, {:enum, :secondary_subdivision}},
    "MY_VUCC_GRIDS" => {:list, :grid},
    "NAME" => :string,
    "NAME_INTL" => :string,
    "NOTES" => :string,
    "NOTES_INTL" => :string,
    "NR_BURSTS" => :integer,
    "NR_PINGS" => :integer,
    "OPERATOR" => :string,
    "OWNER_CALLSIGN" => :string,
    "PFX" => :string,
    "PRECEDENCE" => :string,
    "PROP_MODE" => {:enum, :propagation},
    "PUBLIC_KEY" => :string,
    "QRZCOM_QSO_UPLOAD_DATE" => :date,
    "QRZCOM_QSO_UPLOAD_STATUS" => {:enum, :qso_upload_status},
    "QSLMSG" => :string,
    "QSLMSG_INTL" => :string,
    "QSLRDATE" => :date,
    "QSLSDATE" => :date,
    "QSL_RCVD" => {:enum, :qsl_received},
    "QSL_RCVD_VIA" => {:enum, :qsl_via},
    "QSL_SENT" => {:enum, :qsl_sent},
    "QSL_SENT_VIA" => {:enum, :qsl_via},
    "QSL_VIA" => :string,
    "QSO_COMPLETE" => {:enum, :qso_complete},
    "QSO_DATE" => :date,
    "QSO_DATE_OFF" => :date,
    "QSO_RANDOM" => :boolean,
    "QTH" => :string,
    "QTH_INTL" => :string,
    "RIG" => :string,
    "RIG_INTL" => :string,
    "RST_RCVD" => :string,
    "RST_SENT" => :string,
    "RX_PWR" => :float,
    "SAT_MODE" => :string,
    "SAT_NAME" => :string,
    "SFI" => :integer,
    "SIG" => :string,
    "SIG_INTL" => :string,
    "SIG_INFO" => :string,
    "SIG_INFO_INTL" => :string,
    "SILENT_KEY" => :boolean,
    "SKCC" => :string,
    "SOTA_REF" => :string,
    "SRX" => :string,
    "SRX_STRING" => :string,
    "STATE" => {:enum, :state},
    "STATION_CALLSIGN" => :string,
    "STX" => :integer,
    "STX_STRING" => :string,
    "SUBMODE" => {:enum, :submode},
    "SWL" => :boolean,
    "TEN_TEN" => :integer,
    "TIME_OFF" => :time,
    "TIME_ON" => :time,
    "TX_PWR" => :float,
    "USACA_COUNTIES" => {:list, {:enum, :secondary_subdivision}},
    "UKSMG" => :integer,
    "VE_PROV" => :string,
    "VUCC_GRIDS" => {:list, :grid},
    "WEB" => :string
  }

  @doc """
  Returns {:ok, decoded_value}, {:error, :unknown}, or :error
  """
  def decode(field, value) when is_binary(field) do
    case @field_types[field] do
      nil -> {:error, :unknown}
      type -> do_decode(type, value)
    end
  end

  @doc """
  Returns {:ok, value} or {:error type, value}
  """
  def encode(_field, value) when is_binary(value), do: {:ok, value}

  def encode(field, value) do
    case @field_types[field] do
      nil -> {:error, :unknown, value}
      type -> do_encode(type, value)
    end
  end

  #
  # Type decoding
  #

  # Basic types

  defp do_decode(:string, string), do: {:ok, string}
  defp do_decode(:grid, string), do: {:ok, string}

  defp do_decode(:boolean, "Y"), do: {:ok, true}
  defp do_decode(:boolean, "N"), do: {:ok, false}
  defp do_decode(:boolean, _invalid), do: :error

  defp do_decode(:integer, string) when is_binary(string) do
    case Integer.parse(string) do
      {int, _rest} -> {:ok, int}
      :error -> :error
    end
  end

  defp do_decode(:integer, int) when is_integer(int), do: {:ok, int}
  defp do_decode(:integer, _invalid), do: :error

  defp do_decode(:float, string) when is_binary(string) do
    case Float.parse(string) do
      {float, _rest} -> {:ok, float}
      :error -> :error
    end
  end

  defp do_decode(:float, float) when is_float(float), do: {:ok, float}
  defp do_decode(:float, _invalid), do: :error

  defp do_decode(:date, string) do
    string
    |> Timex.parse("{YYYY}{0M}{0D}")
    |> case do
      {:ok, result} -> {:ok, Timex.to_date(result)}
      {:error, _} -> :error
    end
  end

  defp do_decode(:time, string) do
    with {:error, _} <- Timex.parse(string, "{h24}{m}{s}"),
         {:error, _} <- Timex.parse(string, "{h24}{m}") do
      :error
    else
      {:ok, result} ->
        {:ok, Timex.to_datetime(result)}
    end
  end

  @location_regex ~r/([NESW])(\d\d\d) (\d\d\.\d\d\d)/

  defp do_decode({:coordinate, _}, string) when is_binary(string) do
    with [_, dir, deg, min] <- Regex.run(@location_regex, string) do
      sign = if dir in ["N", "E"], do: 1, else: -1
      deg = String.to_integer(deg)
      min = String.to_float(min) / 60.0

      sign * (deg + min)
    else
      _ -> :error
    end
  end

  defp do_decode({:coordinate, _}, _invalid), do: :error

  # Enums

  defp do_decode({:enum, :band}, string) when is_binary(string),
    do: {:ok, String.downcase(string)}

  defp do_decode({:enum, :band}, _invalid), do: :error

  # Catch-all: just use the string
  defp do_decode({:enum, _}, string), do: {:ok, string}

  # Lists

  defp do_decode({:list, {:enum, :secondary_subdivision}} = list_type, string) do
    # Only list type that uses colons
    do_decode(list_type, string, ":")
  end

  defp do_decode({:list, type}, string, delimeter \\ ",") do
    decodes =
      string
      |> String.split(delimeter)
      |> Enum.map(&do_decode(type, &1))

    if Enum.all?(decodes, &match?({:ok, _}, &1)) do
      values = for {:ok, value} <- decodes, do: value
      {:ok, values}
    else
      :error
    end
  end

  #
  # Type encoding
  #

  # Strings

  defp do_encode(:string, value) when is_binary(value), do: {:ok, value}
  defp do_encode(:string, invalid), do: {:error, :string, invalid}

  # Grids

  defp do_encode(:grid, value) when is_binary(value), do: {:ok, value}
  defp do_encode(:grid, invalid), do: {:error, :grid, invalid}

  # Booleans

  defp do_encode(:boolean, true), do: {:ok, "Y"}
  defp do_encode(:boolean, false), do: {:ok, "N"}
  defp do_encode(:boolean, invalid), do: {:error, :boolean, invalid}

  # Integers

  defp do_encode(:integer, value) when is_integer(value), do: {:ok, Integer.to_string(value)}
  defp do_encode(:integer, invalid), do: {:error, :integer, invalid}

  # Floats

  defp do_encode(:float, value) when is_float(value), do: {:ok, Float.to_string(value)}
  defp do_encode(:float, invalid), do: {:error, :float, invalid}

  # Enums

  defp do_encode({:enum, :band}, value) when is_binary(value), do: {:ok, String.upcase(value)}
  defp do_encode({:enum, _}, value) when is_binary(value), do: {:ok, value}

  # Dates

  defp do_encode(:date, %Date{} = date) do
    case Timex.format(date, "{YYYY}{0M}{0D}") do
      {:ok, string} -> {:ok, string}
      _ -> {:error, :date, date}
    end
  end

  defp do_encode(:date, invalid), do: {:error, :date, invalid}

  # Times

  defp do_encode(:time, %DateTime{} = datetime) do
    case Timex.format(datetime, "{h24}{m}{s}") do
      {:ok, string} -> {:ok, string}
      _ -> {:error, :time, datetime}
    end
  end

  defp do_encode(:time, invalid), do: {:error, :time, invalid}

  # Locations

  defp do_encode({:coordinate, :latitude}, float) when is_float(float) do
    encode_coordinate(float, {"N", "S"})
  end

  defp do_encode({:coordinate, :longitude}, float) when is_float(float) do
    encode_coordinate(float, {"E", "W"})
  end

  # Lists

  defp do_encode({:list, {:enum, :secondary_subdivision}} = list_type, values) do
    # Only list type that uses colons
    do_encode(list_type, values, ":")
  end

  defp do_encode({:list, type}, values, delimeter \\ ",") do
    encodes = Enum.map(values, &do_encode(type, &1))

    if Enum.all?(encodes, &match?({:ok, _}, &1)) do
      strings = for {:ok, string} <- encodes, do: string
      {:ok, Enum.join(strings, delimeter)}
    else
      Enum.find(encodes, &match?({:error, _type, _invalid}, &1))
    end
  end

  # Helper for coordinates
  defp encode_coordinate(float, {pos, neg}) do
    direction = if float < 0, do: neg, else: pos
    float = abs(float)

    deg = trunc(float)
    min = (float - deg) * 60

    # DDD
    deg_format = :io_lib.format("~3.10.0B", [deg]) |> to_string
    # MM.MMM
    min_format = :io_lib.format("~6.3.0f", [min]) |> to_string

    "#{direction}#{deg_format} #{min_format}"
  end
end
