from mplsoccer import PyPizza, FontManager
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

font_normal = FontManager('https://raw.githubusercontent.com/googlefonts/roboto/main/'
                          'src/hinted/Roboto-Regular.ttf')
font_italic = FontManager('https://raw.githubusercontent.com/googlefonts/roboto/main/'
                          'src/hinted/Roboto-Italic.ttf')
font_bold = FontManager('https://raw.githubusercontent.com/google/fonts/main/apache/robotoslab/'
                        'RobotoSlab[wght].ttf')

data_folder = "big5_2025_player_data"

# Load only the relevant columns from each CSV
passing = pd.read_csv(f"{data_folder}/big5_player_passing_2025.csv")[['Player', 'KP', 'PrgP', 'Cmp_percent_Total', 'Pos', 'xA_Expected', 'Final_Third', 'PPA']]
possession = pd.read_csv(f"{data_folder}/big5_player_possession_2025.csv")[['Player', 'Succ_Take', 'PrgC_Carries',]]
defense = pd.read_csv(f"{data_folder}/big5_player_defense_2025.csv")[['Player', 'TklW_Tackles', 'Int']]
time = pd.read_csv(f"{data_folder}/big5_player_playing_time_2025.csv")[['Player', 'Min_Playing.Time']]
sca = pd.read_csv((f"{data_folder}/big5_player_gca_2025.csv"))[['Player', 'SCA_SCA', 'SCA90_SCA', 'GCA_GCA', 'GCA90_GCA']]
misc = pd.read_csv((f"{data_folder}/big5_player_misc_2025.csv"))[['Player', 'Recov']]

# Merge safely
df = passing.merge(possession, on='Player', how='inner') \
            .merge(defense, on='Player', how='inner') \
            .merge(time, on='Player', how='inner') \
            .merge(sca, on='Player', how='inner') \
            .merge(misc, on='Player', how='inner') 

# Filter players with sufficient playing time
df = df[df['Min_Playing.Time'] > 1000]

# Filter midfielders and explicitly make a copy to avoid chained assignment
midfield_positions = ['MF', 'Midfielder', 'CM', 'DM']
df_midfielders = df[df['Pos'].isin(midfield_positions)].copy()

# Calculate per90 metrics and pass percentage using .loc to avoid warnings
df_midfielders.loc[:, 'KP_per90'] = df_midfielders['KP'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders.loc[:, 'xA_per90'] = df_midfielders['xA_Expected'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders.loc[:, 'F3_per90'] = df_midfielders['Final_Third'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders.loc[:, 'PPA_per90'] = df_midfielders['PPA'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders.loc[:, 'PrgP_per90'] = df_midfielders['PrgP'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders.loc[:, 'PassPct'] = df_midfielders['Cmp_percent_Total']  # Already a percentage
df_midfielders.loc[:, 'Dribbles_per90'] = df_midfielders['Succ_Take'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders.loc[:, 'TacklesWon_per90'] = df_midfielders['TklW_Tackles'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders.loc[:, 'PrgC_per90'] = df_midfielders['PrgC_Carries'] / df_midfielders['Min_Playing.Time'] * 90
df_midfielders.loc[:, 'SCA_per90'] = df_midfielders['SCA90_SCA'] 
df_midfielders.loc[:, 'GCA_per90'] = df_midfielders['GCA90_GCA'] 
df_midfielders['Recov'] = (df_midfielders['Recov'] / df_midfielders['Min_Playing.Time'] * 90).astype(float)

# Extract the player row from df_midfielders (where the new columns exist)
player_name = 'Vitinha'
bergvall_row = df_midfielders[df_midfielders['Player'] == player_name]

if bergvall_row.empty:
    raise ValueError(f"{player_name} not found in dataset")

player_stats = [
    bergvall_row['KP_per90'].values[0],
    bergvall_row['xA_per90'].values[0],
    bergvall_row['F3_per90'].values[0],
    bergvall_row['PPA_per90'].values[0],
    bergvall_row['PrgP_per90'].values[0],
    bergvall_row['PassPct'].values[0],
    bergvall_row['Dribbles_per90'].values[0],
    bergvall_row['TacklesWon_per90'].values[0],
    bergvall_row['PrgC_per90'].values[0],
    bergvall_row['SCA_per90'].values[0],
    bergvall_row['GCA_per90'].values[0],
    bergvall_row['Recov'].values[0],
]

# Calculate mean and std for z-score normalization
peer_mean = df_midfielders[['KP_per90', 'xA_per90', 'F3_per90', 'PPA_per90', 'PrgP_per90',
                            'PassPct', 'Dribbles_per90', 'TacklesWon_per90', 'PrgC_per90',
                            'SCA_per90', 'GCA_per90', 'Recov']].mean().tolist()

peer_std = df_midfielders[['KP_per90', 'xA_per90', 'F3_per90', 'PPA_per90', 'PrgP_per90',
                           'PassPct', 'Dribbles_per90', 'TacklesWon_per90', 'PrgC_per90',
                           'SCA_per90', 'GCA_per90', 'Recov']].std().tolist()

# Apply z-score normalization and scale to 0–1 for visualization (clamp between 0 and 1)
values = []
for val, mean, std in zip(player_stats, peer_mean, peer_std):
    if std == 0:
        z = 0
    else:
        z = (val - mean) / std
    # Optional: scale to 0–1 using a sigmoid-like clamp, or custom min/max range
    scaled = (z + 2) / 4  # this maps z ≈ -2 to 0, z ≈ +2 to 1
    values.append(np.clip(scaled, 0, 1))


params = ['Key Passes', 'xA', 'Final ⅓ Passes', 'Penalty Area Passes', 'Progressive Passes', 'Pass %', 'Dribbles', 'Tackles Won', 'Progressive Carries', 'SCA', 'GCA', 'Ball Recoveries']
values_100 = [v * 100 for v in values]
values_100_rounded = [round(v) for v in values_100]

# Create pizza plot
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
    0.515, 0.97, f"{player_name} - Paris Saint-Germain", size=18,
    ha="center", fontproperties=font_bold.prop, color="#000000"
)

fig.text(
    0.515, 0.942,
    "Percentile Rank vs Top-Five League Midfielders | Season 2024-25",
    size=15,
    ha="center", fontproperties=font_bold.prop, color="#000000"
)

# add credits
CREDIT_1 = "data: statsbomb viz fbref"
CREDIT_2 = "Amongst players with a minimum of 1000 minutes recorded"

fig.text(
    0.99, 0.005, f"{CREDIT_1}\n{CREDIT_2}", size=9,
    fontproperties=font_italic.prop, color="#000000",
    ha="right"
)

plt.show()
