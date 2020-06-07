# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Lumber.Repo.insert!(%Lumber.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Lumber.Repo
alias Lumber.Contests.Contest

# May 12, 2020 at 1Z
{:ok, start_date, 0} = DateTime.from_iso8601("2020-05-12T01:00:00Z")

# Create the first year of WWSAC contests
contests =
  Enum.map(0..51, fn week ->
    started_at = Timex.shift(start_date, weeks: week)
    submissions_before = Timex.shift(started_at, days: 1)

    Repo.insert!(%Contest{
      title: "WWSAC \##{week + 1}",
      started_at: started_at,
      submissions_before: submissions_before,
      type: "WWSAC"
    })
  end)

IO.puts("Created #{length(contests)} WWSAC contests")
