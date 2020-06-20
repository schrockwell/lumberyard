defmodule Lumber.Wwsac.Changeset do
  import Ecto.Changeset

  def update_callsign(changeset, field) do
    changeset
    |> get_change(field)
    |> case do
      string when is_binary(string) ->
        put_change(changeset, field, normalize_callsign(string))

      _ ->
        changeset
    end
  end

  defp normalize_callsign(callsign) do
    callsign |> String.trim() |> String.upcase()
  end

  def trim_field(changeset, field) do
    case get_change(changeset, field) do
      string when is_binary(string) ->
        put_change(changeset, field, String.trim(string))

      _ ->
        changeset
    end
  end

  def validate_age_group(changeset) do
    validate_inclusion(changeset, :age_group, option_values(age_group_options()))
  end

  def validate_power_level(changeset) do
    validate_inclusion(changeset, :power_level, option_values(power_level_options()))
  end

  defp option_values(list) do
    Enum.map(list, &elem(&1, 1))
  end

  def age_group_options do
    [
      {"Please select...", ""},
      {"Youth YL (26 and under)", "YYL"},
      {"YL (over 26)", "YL"},
      {"Youth (26 and under)", "Y"},
      {"OM (over 26)", "OM"}
    ]
  end

  def power_level_options do
    [
      {"Please select...", ""},
      {"QRP (5W max)", "QRP"},
      {"Low Power (100W max)", "LP"},
      {"High Power (1,500W max)", "HP"}
    ]
  end
end
