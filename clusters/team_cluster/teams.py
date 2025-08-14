from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from math import pi

data_folder = "big5_2025_team_data"
passing = pd.read_csv(f"{data_folder}/big5_team_passing_2025.csv")[['Squad', 'Comp', 'Team_or_Opponent', 'PrgP', 'Final_Third', 'Cmp_percent_Total', 'Cmp_Short', 'Cmp_percent_Short', 'Cmp_Medium', 'Cmp_percent_Medium', 'Cmp_Long', 'Cmp_percent_Long', 'xAG', 'xA_Expected' ]]
possesion = pd.read_csv(f"{data_folder}/big5_team_possession_2025.csv")[['Squad', 'Comp', 'Team_or_Opponent', 'Poss', 'Touches_Touches', 'Def 3rd_Touches','Mid 3rd_Touches', 'Att 3rd_Touches', 'Att Pen_Touches', 'Carries_Carries', 'PrgDist_Carries', 'Final_Third_Carries', 'CPA_Carries', 'Succ_Take']]
defense = pd.read_csv(f"{data_folder}/big5_team_defense_2025.csv")[['Squad', 'Comp', 'Team_or_Opponent', 'Tkl_Tackles', 'TklW_Tackles', 'Int', 'Def 3rd_Tackles','Mid 3rd_Tackles','Att 3rd_Tackles', 'Tkl+Int', 'Sh_Blocks','Pass_Blocks', 'Clr' ]]
sca = pd.read_csv(f"{data_folder}/big5_team_gca_2025.csv")[['Squad', 'Comp', 'Team_or_Opponent', 'SCA_SCA', 'SCA90_SCA', 'PassLive_SCA', 'TO_SCA','Sh_SCA','Fld_SCA','Def_SCA','GCA_GCA', 'GCA90_GCA', 'PassLive_GCA','PassDead_GCA','TO_GCA','Sh_GCA','Fld_GCA','Def_GCA']]
shooting = pd.read_csv(f"{data_folder}/big5_team_shooting_2025.csv")[['Squad', 'Comp', 'Team_or_Opponent', 'Sh_per_90_Standard', 'SoT_per_90_Standard', 'SoT_percent_Standard', 'G_per_Sh_Standard', 'G_per_SoT_Standard', 'xG_Expected', 'npxG_per_Sh_Expected', 'G_minus_xG_Expected', 'np:G_minus_xG_Expected']]
misc = pd.read_csv(f"{data_folder}/big5_team_misc_2025.csv")[['Squad', 'Comp', 'Team_or_Opponent', 'Recov', 'Won_percent_Aerial', 'Fls' ]]
passing_type = pd.read_csv(f"{data_folder}/big5_team_passing_types_2025.csv")[['Squad','Comp', 'Team_or_Opponent','Att', 'Live_Pass','TB_Pass', 'Sw_Pass']]

df = passing.merge(possesion, on=['Squad','Comp','Team_or_Opponent'], how='inner')\
            .merge(defense, on=['Squad','Comp','Team_or_Opponent'], how='inner') \
            .merge(sca, on=['Squad','Comp','Team_or_Opponent'], how='inner') \
            .merge(shooting, on=['Squad','Comp','Team_or_Opponent'], how='inner') \
            .merge(misc, on=['Squad','Comp','Team_or_Opponent'], how='inner') \
            .merge(passing_type, on=['Squad','Comp','Team_or_Opponent'], how='inner')

# Filter for 'team' stats
team_df = df[df['Team_or_Opponent'] == 'team']

# Filter for 'opponent' stats
opponent_df = df[df['Team_or_Opponent'] == 'opponent']

# Save to CSV
# team_df.to_csv("big5_team_stats_2025_team.csv", index=False)
# opponent_df.to_csv("big5_team_stats_2025_opponent.csv", index=False)

# ===== 1. Select numeric columns for clustering =====
numeric_cols = team_df.select_dtypes(include=['float64', 'int64']).columns
X = team_df[numeric_cols]

# ===== 2. Scale the data =====
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# ===== 3. KMeans clustering =====
kmeans = KMeans(n_clusters=10, random_state=42)
team_df["Cluster"] = kmeans.fit_predict(X_scaled)  # <-- Now 'Cluster' exists

# Optional: give names to clusters (based on your heatmap analysis)
cluster_names = {
    0: "Possession Builders",
    1: "Balanced Attackers",
    2: "High-Tempo Elite Attack",
    3: "Defensive Stability First",
    4: "Defensive Blockers",
    5: "Overperforming Finishers",
    6: "Efficient Attackers",
    7: "Direct Threat Makers",
    8: "High Work-Rate Creators",
    9: "Solid Mid-Block Teams"
}
team_df["Cluster_Name"] = team_df["Cluster"].map(cluster_names)

# ===== 4. PCA for visualization =====
pca = PCA(n_components=2)
pca_result = pca.fit_transform(X_scaled)
team_df["PCA1"] = pca_result[:, 0]
team_df["PCA2"] = pca_result[:, 1]

# ===== 5. Plot =====
from adjustText import adjust_text

plt.figure(figsize=(10, 7))
texts = []  # store text objects for adjustment

# Scatter plot by cluster
for cluster, data in team_df.groupby("Cluster"):
    plt.scatter(
        data["PCA1"], 
        data["PCA2"], 
        label=cluster_names.get(cluster, f"Cluster {cluster}"), 
        alpha=0.7
    )

# Label top 2 teams in each cluster by xG
for cluster, data in team_df.groupby("Cluster"):
    top_teams = data.sort_values("xG_Expected", ascending=False).head(2)
    for _, row in top_teams.iterrows():
        texts.append(
            plt.text(
                row["PCA1"], 
                row["PCA2"], 
                row["Squad"], 
                fontsize=9, 
                weight="bold"
            )
        )

# Adjust labels to avoid overlap
adjust_text(texts, arrowprops=dict(arrowstyle="-", color="gray", lw=0.5))

plt.xlabel("PCA 1")
plt.ylabel("PCA 2")
plt.title("PCA of Team Clusters")
plt.legend(fontsize=8, loc="best")
plt.subplots_adjust(bottom=0.12)

plt.figtext(
    0.5, 0.02,
    "Note: Top 2 teams in each cluster by xG are labeled", 
    ha="center", fontsize=9, style="italic"
)

plt.show()
