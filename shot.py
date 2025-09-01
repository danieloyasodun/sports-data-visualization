from nba_api.stats.endpoints import shotchartdetail
import pandas as pd

# Example: Stephen Curry's shots in 2022-23
player_id = 201939   # Curry's ID
team_id = 1610612744 # Golden State Warriors

shots = shotchartdetail.ShotChartDetail(
    team_id=team_id,
    player_id=player_id,
    season_type_all_star='Regular Season',
    season_nullable='2022-23',
    context_measure_simple='FGA'  # Field goal attempts
)

# Convert to DataFrame
shot_df = shots.get_data_frames()[0]

# Preview
print(shot_df.head())

# Save to CSV
shot_df.to_csv("curry_shots_2022_23.csv", index=False)

print("Saved to curry_shots_2022_23.csv")

