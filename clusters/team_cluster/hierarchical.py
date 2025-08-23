import pandas as pd
from sklearn.preprocessing import StandardScaler
from scipy.cluster.hierarchy import dendrogram, linkage, fcluster
import matplotlib.pyplot as plt

# --- Load dataset ---
df = pd.read_csv("big5_team_stats_2025_team.csv")

# --- Keep only team rows ---
df = df[df["Team_or_Opponent"] == "team"]

# --- Select numeric features ---
features = [
    "PrgP","Final_Third","Cmp_percent_Total","Cmp_Short","Cmp_percent_Short",
    "Cmp_Medium","Cmp_percent_Medium","Cmp_Long","Cmp_percent_Long","xAG",
    "xA_Expected","Poss","Touches_Touches","Def 3rd_Touches","Mid 3rd_Touches",
    "Att 3rd_Touches","Att Pen_Touches","Carries_Carries","PrgDist_Carries",
    "Final_Third_Carries","CPA_Carries","Succ_Take","Tkl_Tackles","TklW_Tackles",
    "Int","Def 3rd_Tackles","Mid 3rd_Tackles","Att 3rd_Tackles","Tkl+Int",
    "Sh_Blocks","Pass_Blocks","Clr","SCA_SCA","SCA90_SCA","PassLive_SCA","TO_SCA",
    "Sh_SCA","Fld_SCA","Def_SCA","GCA_GCA","GCA90_GCA","PassLive_GCA","PassDead_GCA",
    "TO_GCA","Sh_GCA","Fld_GCA","Def_GCA","Sh_per_90_Standard","SoT_per_90_Standard",
    "SoT_percent_Standard","G_per_Sh_Standard","G_per_SoT_Standard","xG_Expected",
    "npxG_per_Sh_Expected","G_minus_xG_Expected","np:G_minus_xG_Expected","Recov",
    "Won_percent_Aerial","Fls","Att","Live_Pass","TB_Pass","Sw_Pass"
]

X = df[features].fillna(0)

# --- Scale the features ---
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# --- Hierarchical clustering ---
Z = linkage(X_scaled, method="ward")

# --- Plot dendrogram ---
plt.figure(figsize=(12,6))
dendrogram(Z, labels=df["Squad"].values, leaf_rotation=90, leaf_font_size=8)
plt.title("Hierarchical Clustering Dendrogram - Big 5 Leagues")
plt.xlabel("Teams")
plt.ylabel("Distance")
plt.tight_layout()
plt.show()

# --- Cut into clusters (e.g., 5 clusters, tweak as needed) ---
clusters = fcluster(Z, t=5, criterion='maxclust')
df["Cluster"] = clusters

# --- Table of teams with their cluster ---
cluster_table = df[["Squad", "Comp", "Cluster"]].sort_values("Cluster")
print(cluster_table)

# --- Cluster profile summary (average stats per cluster) ---
cluster_profiles = df.groupby("Cluster")[features].mean().round(2)
print(cluster_profiles)

# --- Save results ---
cluster_table.to_csv("big5_hierarchical_clusters.csv", index=False)
cluster_profiles.to_csv("big5_cluster_profiles.csv")
