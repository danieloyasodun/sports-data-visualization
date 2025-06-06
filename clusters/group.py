from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
import pandas as pd
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from math import pi

data_folder = "big5_2025_player_data"
passing = pd.read_csv(f"{data_folder}/big5_player_passing_2025.csv")[['Player', 'KP', 'PrgP', 'Cmp_percent_Total', 'Pos', 'xA_Expected', 'Final_Third', 'PPA', 'xAG']]
possession = pd.read_csv(f"{data_folder}/big5_player_possession_2025.csv")[['Player', 'Succ_Take', 'PrgC_Carries', 'CPA_Carries', 'Final_Third_Carries', 'PrgR_Receiving', 'Rec_Receiving']]
defense = pd.read_csv(f"{data_folder}/big5_player_defense_2025.csv")[['Player', 'TklW_Tackles', 'Int']]
time = pd.read_csv(f"{data_folder}/big5_player_playing_time_2025.csv")[['Player', 'Min_Playing.Time']]
sca = pd.read_csv(f"{data_folder}/big5_player_gca_2025.csv")[['Player', 'SCA90_SCA', 'PassLive_GCA', 'GCA90_GCA']]
shooting = pd.read_csv(f"{data_folder}/big5_player_shooting_2025.csv")[['Player', 'Sh_per_90_Standard', 'SoT_per_90_Standard', 'xG_Expected', 'npxG_Expected', 'G_minus_xG_Expected']]
misc = pd.read_csv(f"{data_folder}/big5_player_misc_2025.csv")[['Player', 'Recov']]
passing_type = pd.read_csv(f"{data_folder}/big5_player_passing_types_2025.csv")[['Player', 'TB_Pass', 'Att']]

# Merge datasets
df = passing.merge(possession, on='Player', how='inner') \
            .merge(defense, on='Player', how='inner') \
            .merge(time, on='Player', how='inner') \
            .merge(sca, on='Player', how='inner') \
            .merge(shooting, on='Player', how='inner') \
            .merge(misc, on='Player', how='inner') \
            .merge(passing_type, on='Player', how='inner')

# Per 90 stats
df['xG_per90'] = df['xG_Expected'] / df['Min_Playing.Time'] * 90
df['npXG_per90'] = df['npxG_Expected'] / df['Min_Playing.Time'] * 90
df['Sh_per90'] = df['Sh_per_90_Standard']  # already per90
df['SoT_per90'] = df['SoT_per_90_Standard']  # already per90
df['SCA_per90'] = df['SCA90_SCA']
df['GCA_per90'] = df['GCA90_GCA']
df['PassLive_SCA_per90'] = df['PassLive_GCA'] / df['Min_Playing.Time'] * 90
df['TB_per90'] = df['TB_Pass'] / df['Min_Playing.Time'] * 90
df['KP_per90'] = df['KP'] / df['Min_Playing.Time'] * 90
df['PrgP_per90'] = df['PrgP'] / df['Min_Playing.Time'] * 90
df['PPA_per90'] = df['PPA'] / df['Min_Playing.Time'] * 90
df['F3P_per90'] = df['Final_Third'] / df['Min_Playing.Time'] * 90
df['Succ_Take_per90'] = df['Succ_Take'] / df['Min_Playing.Time'] * 90
df['PrgC_per90'] = df['PrgC_Carries'] / df['Min_Playing.Time'] * 90
df['CPA_per90'] = df['CPA_Carries'] / df['Min_Playing.Time'] * 90
df['F3C_per90'] = df['Final_Third_Carries'] / df['Min_Playing.Time'] * 90
df['TklW_per90'] = df['TklW_Tackles'] / df['Min_Playing.Time'] * 90
df['Recov_per90'] = df['Recov'] / df['Min_Playing.Time'] * 90
df['PrgR_per90'] = df['PrgR_Receiving'] / df['Min_Playing.Time'] * 90
df['Rec_per90'] = df['Rec_Receiving'] / df['Min_Playing.Time'] * 90
df['xA_per90'] = df['xA_Expected'] / df['Min_Playing.Time'] * 90
df['xAG_per90'] = df['xAG'] / df['Min_Playing.Time'] * 90


df = df[df['Min_Playing.Time'] > 600]
# Keep players with 'FW' anywhere in the 'Pos' string
df = df[df['Pos'].str.contains('FW', na=False)]

features = [
    # Scoring
    'xG_per90',               # scoring volume
    'Sh_per90',               # shooting frequency
    'SoT_per90',              # accuracy proxy
    'npXG_per90',
    'G_minus_xG_Expected',

    # Creativty
    'SCA_per90',              # creativity
    'GCA_per90',              # top-level playmaking
    'PassLive_SCA_per90',     # live passing impact
    'TB_per90',               # through balls
    'KP_per90',          
    'PrgP_per90',
    'PPA_per90',
    'F3P_per90',
    'Att',
    'xA_per90',
    'xAG_per90',

    # Ball Carrying
    'Succ_Take_per90',        # dribbling threat
    'PrgC_per90',             # carries forward
    'CPA_per90',              # carries into penalty area
    'F3C_per90',

    # Defnsive effort
    'TklW_per90',             # defensive effort
    'Recov_per90',

    # Misc
    'PrgR_per90',
    'Rec_per90'
]

df = df.dropna(subset=features)
df = df.drop_duplicates(subset=['Player'], keep='last')

scaler = StandardScaler()
X = scaler.fit_transform(df[features])

k = 9
kmeans = KMeans(n_clusters=k, random_state=42)
df['Cluster'] = kmeans.fit_predict(X)

cluster_profiles = df.groupby('Cluster')[features].mean()

scaler = StandardScaler()
cluster_profiles_scaled = pd.DataFrame(
    scaler.fit_transform(cluster_profiles),
    index=cluster_profiles.index,
    columns=cluster_profiles.columns
)

cluster_labels = {
    0: "Support Forward",           # Decent xG, KP; moderate creativity; secondary role
    1: "All-Around Attacker",       # High xG, xA, GCA, KP, PrgP — very complete profile
    2: "Elite Creator",             # Very high xA, xAG, KP; top-tier creative output
    3: "Link Play Forward",         # Modest xG/xA, but contributes via buildup play
    4: "Secondary Creator",         # Balanced creator with supporting metrics
    5: "Dribbling Playmaker",       # Strong GCA, PrgP, PrgC — creates via movement
    6: "Pressing Forward",          # Low goal output, but excels in defensive + recovery metrics
    7: "Ball-Dominant Star",        # High across the board — focal attacking hub
    8: "Peripheral Forward"         # Low involvement in most metrics — possible wide/passive role
}
cluster_profiles_scaled.index = cluster_profiles_scaled.index.map(cluster_labels)

df['Style'] = df['Cluster'].map(cluster_labels)

from adjustText import adjust_text
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib import patheffects

# Define your palette and map cluster names to colors
palette = sns.color_palette('tab10', df['Style'].nunique())
style_color_map = {style: color for style, color in zip(df['Style'].unique(), palette)}

# Fit PCA
pca = PCA(n_components=2)
pca_result = pca.fit_transform(X)
df['PCA1'] = pca_result[:, 0]
df['PCA2'] = pca_result[:, 1]

# Scatter plot
plt.figure(figsize=(12, 8))
sns.scatterplot(
    x='PCA1', y='PCA2',
    hue='Style', data=df,
    palette=style_color_map,
    alpha=0.7, s=80
)

# Select top 2 players per cluster by xG_per90
top_labeled = (
    df.sort_values('PrgC_per90', ascending=False)
      .groupby('Style')
      .head(2)
)

# Add text labels with matching colors
texts = []
for _, row in top_labeled.iterrows():
    color = style_color_map[row['Style']]
    text = plt.text(
        row['PCA1'], row['PCA2'], row['Player'],
        fontsize=9, color=color,
        path_effects=[
            patheffects.withStroke(linewidth=2.5, foreground='black')
        ]
    )
    texts.append(text)

# Adjust text to prevent overlaps
adjust_text(texts, arrowprops=dict(arrowstyle='->', color='black', lw=0.5))

plt.title("PCA Projection of Player Styles")
plt.xlabel(f"PCA 1 ({pca.explained_variance_ratio_[0]*100:.1f}% variance)")
plt.ylabel(f"PCA 2 ({pca.explained_variance_ratio_[1]*100:.1f}% variance)")
plt.legend(title='Style', bbox_to_anchor=(1.05, 1), loc='upper left')

# Add footnote
plt.figtext(0.5, 0.01, "Note: Top 2 players per cluster in PrgC_per90 are labeled", ha='center', fontsize=10, style='italic', color='gray')

plt.tight_layout(rect=[0, 0.03, 1, 1])
plt.show()

