import pandas as pd

"""
df = pd.read_csv("team_game_data.csv")

teams = df[["season", "off_team", "off_win"]].copy()
teams.rename(columns={"off_team": "team", "off_win": "win"}, inplace=True)

summary = (
    teams.groupby(["season", "team"])["win"]
    .agg(
        wins="sum",
        games="count"
    )
    .reset_index()
)

summary["losses"] = summary["games"] - summary["wins"]
summary["win_pct"] = (summary["wins"] / summary["games"]).round(3)

summary = summary[["season", "team", "wins", "losses", "games", "win_pct"]]

summary.to_csv("team_win_loss_by_season.csv", index=False)
"""

"""
summary = pd.read_csv("team_win_loss_by_season.csv")
df_2024 = pd.read_csv("nba_2024_combined.csv")

new_summary = df_2024[["Team", "W", "L", "G", "WL_pct"]].copy()

new_summary.insert(0, "season", 2024)

new_summary.rename(columns={
    "Team": "team",
    "W": "wins",
    "L": "losses",
    "G": "games",
    "WL_pct": "win_pct"
}, inplace=True)

combined = pd.concat([summary, new_summary], ignore_index=True)

combined.to_csv("team_win_loss_by_season.csv", index=False)
"""

df = pd.read_csv("team_win_loss_by_season.csv")

df = df.sort_values(by=["season", "team"]).reset_index(drop=True)

df.to_csv("team_win_loss_by_season.csv", index=False)