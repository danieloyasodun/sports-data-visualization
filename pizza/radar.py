from mplsoccer import PyPizza, FontManager
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy.stats import percentileofscore

# Load fonts
font_normal = FontManager('https://raw.githubusercontent.com/googlefonts/roboto/main/src/hinted/Roboto-Regular.ttf')
font_italic = FontManager('https://raw.githubusercontent.com/googlefonts/roboto/main/src/hinted/Roboto-Italic.ttf')
font_bold = FontManager('https://raw.githubusercontent.com/google/fonts/main/apache/robotoslab/RobotoSlab[wght].ttf')

# Load data
data_folder = "big5_2025_player_data"
passing = pd.read_csv(f"{data_folder}/big5_player_passing_2025.csv")[['Player', 'KP', 'PrgP', 'Cmp_percent_Total', 'Pos', 'xA_Expected', 'Final_Third', 'PPA']]
possession = pd.read_csv(f"{data_folder}/big5_player_possession_2025.csv")[['Player', 'Succ_Take', 'PrgC_Carries']]
defense = pd.read_csv(f"{data_folder}/big5_player_defense_2025.csv")[['Player', 'TklW_Tackles', 'Int']]
time = pd.read_csv(f"{data_folder}/big5_player_playing_time_2025.csv")[['Player', 'Min_Playing.Time']]
sca = pd.read_csv(f"{data_folder}/big5_player_gca_2025.csv")[['Player', 'SCA_SCA', 'SCA90_SCA', 'GCA_GCA', 'GCA90_GCA']]
misc = pd.read_csv(f"{data_folder}/big5_player_misc_2025.csv")[['Player', 'Recov']]

# Merge datasets
df = passing.merge(possession, on='Player', how='inner') \
            .merge(defense, on='Player', how='inner') \
            .merge(time, on='Player', how='inner') \
            .merge(sca, on='Player', how='inner') \
            .merge(misc, on='Player', how='inner') 

# Filter by minutes and position
df = df[df['Min_Playing.Time'] > 10]
midfield_positions = ['MF', 'DF']
# Create regex pattern that matches any of the midfield positions as substrings
pattern = '|'.join(midfield_positions)
df = df.drop_duplicates(subset='Player', keep='first')
df_midfielders = df[
    (df['Min_Playing.Time'] > 10) & 
    (df['Pos'].str.contains(pattern, regex=True, na=False))
].copy()

# Per90 calculations
df_midfielders['KP_per90'] = df_midfielders['KP'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders['xA_per90'] = df_midfielders['xA_Expected'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders['F3_per90'] = df_midfielders['Final_Third'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders['PPA_per90'] = df_midfielders['PPA'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders['PrgP_per90'] = df_midfielders['PrgP'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders['PassPct'] = df_midfielders['Cmp_percent_Total']
df_midfielders['Dribbles_per90'] = df_midfielders['Succ_Take'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders['TacklesWon_per90'] = df_midfielders['TklW_Tackles'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders['PrgC_per90'] = df_midfielders['PrgC_Carries'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders['SCA_per90'] = df_midfielders['SCA90_SCA']
df_midfielders['GCA_per90'] = df_midfielders['GCA90_GCA']
df_midfielders['Recov'] = df_midfielders['Recov'] / df_midfielders['Min_Playing.Time'] * 90

print("Players with >1000 minutes:", df_midfielders.shape[0])

# Select player
player_name = 'Pedri'
player_row = df_midfielders[df_midfielders['Player'] == player_name]

if player_row.empty:
    raise ValueError(f"{player_name} not found in dataset")

# Columns and labels
stat_columns = ['KP_per90', 'xA_per90', 'F3_per90', 'PPA_per90', 'PrgP_per90',
                'PassPct', 'Dribbles_per90', 'TacklesWon_per90', 'PrgC_per90',
                'SCA_per90', 'GCA_per90', 'Recov']

params = ['Key Passes', 'xA', 'Final ⅓ Passes', 'Penalty Area Passes', 'Progressive Passes',
          'Pass %', 'Dribbles', 'Tackles Won', 'Progressive Carries',
          'SCA', 'GCA', 'Ball Recoveries']

# Calculate percentile scores
values_100_rounded = []
for col in stat_columns:
    player_val = player_row[col].values[0]
    peer_vals = df_midfielders[col].dropna().values
    if pd.isna(player_val) or len(peer_vals) == 0:
        # Handle missing player value or empty peer values by assigning 0 or some default
        perc = 0
    else:
        perc = percentileofscore(peer_vals, player_val, kind='rank')

    values_100_rounded.append(round(perc))

print(values_100_rounded)
print(f"\nStat values for {player_name}:\n" + "-"*40)
for label, col in zip(params, stat_columns):
    value = player_row[col].values[0]
    print(f"{label:<25}: {value:.2f}")


# Create radar chart
baker = PyPizza(
    params=params,
    straight_line_color="#000000",
    straight_line_lw=1,
    last_circle_lw=1,
    other_circle_lw=1,
    other_circle_ls="-."
)

fig, ax = baker.make_pizza(
    values_100_rounded,
    figsize=(8, 8),
    param_location=110,
    kwargs_slices=dict(
        facecolor="cornflowerblue", edgecolor="#000000",
        zorder=2, linewidth=1
    ),
    kwargs_params=dict(
        color="#000000", fontsize=12,
        fontproperties=font_normal.prop, va="center"
    ),
    kwargs_values=dict(
        color="#000000", fontsize=12,
        fontproperties=font_normal.prop, zorder=3,
        bbox=dict(
            edgecolor="#000000", facecolor="cornflowerblue",
            boxstyle="round,pad=0.2", lw=1
        )
    )
)

fig.text(
    0.515, 0.97, f"{player_name} - FC Barcelona", size=18,
    ha="center", fontproperties=font_bold.prop, color="#000000"
)

fig.text(
    0.515, 0.942,
    "Percentile Rank vs Top-Five League Midfielders | Season 2024-25",
    size=15,
    ha="center", fontproperties=font_bold.prop, color="#000000"
)

fig.text(
    0.99, 0.005, "data: statsbomb viz fbref\nAmongst players with a minimum of 1000 minutes recorded",
    size=9, fontproperties=font_italic.prop, color="#000000", ha="right"
)

plt.show()

