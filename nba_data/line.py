import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.offsetbox import OffsetImage, AnnotationBbox

# Load data
df = pd.read_csv("team_win_loss_by_season.csv")
df = df.sort_values(by=["team", "season"])

team_colors = {
    "ATL": "#c1d32f", "BOS": "#007A33", "BKN": "#000000", "CHA": "#1D1160",
    "CHI": "#CE1141", "CLE": "#860038", "DAL": "#00538C", "DEN": "#0E2240",
    "DET": "#C8102E", "GSW": "#1D428A", "HOU": "#ba0c2f", "IND": "#002D62",
    "LAC": "#C8102E", "LAL": "#552583", "MEM": "#5D76A9", "MIA": "#98002E",
    "MIL": "#00471B", "MIN": "#0C2340", "NOP": "#85714d", "NYK": "#006BB6",
    "OKC": "#007AC1", "ORL": "#0077C0", "PHI": "#ed174c", "PHX": "#e56020",
    "POR": "#E03A3E", "SAC": "#5A2D81", "SAS": "#C4CED4", "TOR": "#753bbd",
    "UTA": "#f9a01b", "WAS": "#002B5C"
}

team_logos = {team: f"logos/{team}.png" for team in team_colors.keys()}

# Define conferences
east_teams = [
    "ATL", "BOS", "BKN", "CHA", "CHI", "CLE", "DET",
    "IND", "MIA", "MIL", "NYK", "ORL", "PHI", "TOR", "WAS"
]
west_teams = [
    "DAL", "DEN", "GSW", "HOU", "LAC", "LAL", "MEM",
    "MIN", "NOP", "OKC", "PHX", "POR", "SAC", "SAS", "UTA"
]

df["conference"] = df["team"].apply(lambda t: "East" if t in east_teams else "West")

# Create subplots
fig, axes = plt.subplots(1, 2, figsize=(18, 8), sharey=True)

def plot_conference(ax, teams_list, title, show_legend=False):
    conf_df = df[df["team"].isin(teams_list)]
    for team, data in conf_df.groupby("team"):
        color = team_colors.get(team, "#333333")
        ax.plot(data["season"], data["wins"], label=team, color=color, linewidth=2)

    ax.set_title(title, fontsize=14)
    ax.set_xlabel("Season (start year)")
    ax.set_ylabel("Wins")
    ax.grid(True, alpha=0.3)
    
    if show_legend:
        ax.legend(bbox_to_anchor=(1.05, 1), loc="upper left", fontsize=8)

# Plot each conference
plot_conference(axes[0], east_teams, "Eastern Conference", show_legend=True)  # legend on East
plot_conference(axes[1], west_teams, "Western Conference")                     # no legend here


# Overall title and note
fig.suptitle("NBA Team Wins by Season (Start Year of Season)", fontsize=16, y=1.03)
fig.text(
    0.5, -0.05,
    "Note: The 'Season' column represents the start year of the season (e.g., 2024 = 2024–25 season).",
    ha="center", fontsize=10, style="italic"
)

plt.tight_layout()
plt.show()