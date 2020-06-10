defmodule Lumber.WwsacResults do
  import Ecto.Query

  alias Lumber.Repo
  alias Lumber.Wwsac.Submission

  defmodule Category do
    defstruct [:age_group, :power_level, :title, :index]
  end

  def all_categories do
    [
      %Category{index: 0, age_group: "YL", power_level: "HP", title: "YL High Power"},
      %Category{index: 1, age_group: "YL", power_level: "LP", title: "YL Low Power"},
      %Category{index: 2, age_group: "YL", power_level: "QRP", title: "YL QRP"},
      # ---
      %Category{index: 3, age_group: "YYL", power_level: "HP", title: "Youth YL High Power"},
      %Category{index: 4, age_group: "YYL", power_level: "LP", title: "Youth YL Low Power"},
      %Category{index: 5, age_group: "YYL", power_level: "QRP", title: "Youth YL QRP"},
      # ---
      %Category{index: 6, age_group: "Y", power_level: "HP", title: "Youth High Power"},
      %Category{index: 7, age_group: "Y", power_level: "LP", title: "Youth Low Power"},
      %Category{index: 8, age_group: "Y", power_level: "QRP", title: "Youth QRP"},
      # ---
      %Category{index: 9, age_group: "OM", power_level: "HP", title: "OM High Power"},
      %Category{index: 10, age_group: "OM", power_level: "LP", title: "OM Low Power"},
      %Category{index: 11, age_group: "OM", power_level: "QRP", title: "OM QRP"}
    ]
  end

  def get_all_leaderboards(year) do
    all_categories()
    |> Task.async_stream(fn category ->
      %{
        category: category,
        operators: get_leaderboard(category, year)
      }
    end)
    |> Stream.filter(&match?({:ok, _}, &1))
    |> Stream.map(&elem(&1, 1))
    |> Enum.sort_by(& &1.category.index)
  end

  def get_leaderboard(category, year) do
    beginning_of_year =
      year |> Timex.beginning_of_year() |> Timex.to_datetime() |> Timex.beginning_of_day()

    end_of_year = year |> Timex.end_of_year() |> Timex.to_datetime() |> Timex.end_of_day()

    from(s in Submission,
      join: c in assoc(s, :contest),
      where: c.starts_at >= ^beginning_of_year and c.starts_at <= ^end_of_year,
      where: s.age_group == ^category.age_group and s.power_level == ^category.power_level,
      where: is_nil(s.rejected_at),
      where: not is_nil(s.completed_at),
      group_by: s.callsign,
      select: %{
        callsign: s.callsign,
        qsos: sum(s.qso_count),
        points: sum(s.final_score),
        count: count(s.id)
      }
    )
    |> Repo.all()
    |> Enum.sort_by(& &1.points, &>=/2)
    |> Enum.take(10)
  end

  def all_years do
    Enum.reverse(2020..DateTime.utc_now().year)
  end
end
