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
alias Lumber.Schedule.Contest

# Create the first five years of WWSAC contests
Lumber.Wwsac.seed_contests(1, 260)
