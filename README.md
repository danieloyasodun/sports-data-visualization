## Sports Analytics: Uncovering Insights Through Data

### Description
This repository is a collection of projects and experiments where I practice and learn data visualization using R and Python. I explore NBA stats and play-by-play data from [here](https://github.com/shufinskiy/nba_data) to create visualizations, inclusing shot charts, heatmaps and other anlytical graphics. The goal is to develope a deeper understanding of data story telling and sports analytics.

### worldfootballR
Plots made using worldfootballR located [here](https://github.com/danieloyasodun/sports-data-visualization/blob/main/worldfootballr/README.md)

---

### Team Clustering
[`team_clusters`](https://github.com/danieloyasodun/sports-data-visualization/tree/main/clusters/team_cluster)

[`pca`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/clusters/team_cluster/pca.png)
[`pca1`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/clusters/team_cluster/pca1.png)
[`heatmap`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/clusters/team_cluster/heatmap.png)
[`elbow`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/clusters/team_cluster/elbow.png)

---

### Player Style Clustering: Grouping Attackers by profile
[`clusters`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/clusters/group.py)

[`pca`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/clusters/PCA.png)
[`heatmap`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/clusters/heatmap.png)
[`elbow`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/clusters/elbow.png)
[`clustered data`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/clusters/big5_forwards_clustered.csv)

This project uses **unsupervised machine learning** to identify and group **attacking players** based on their performance metrics during the **2024–25 season** in Europe’s Big 5 Leagues. Rather than relying on subjective labels like "striker" or "winger," this approach groups players by how they *actually* play — using data-driven player profiles.

#### Objective:
To identify and label distinct attacking profiles (e.g., Support Forward, Ball-Dominant Star, Elite Creator) using underlying contributions — not just headline stats like goals or assists.

#### Workflow Summary:  
  1. Feature Engineering
    Cleaned and selected key per-90 stats to describe attacking tendencies, including:
     - `xG`, `xA`, `Shots`, `Key Passes`, `Progressive Passes`, `Dribbles`, `Carries into Final ⅓`, `Penalty Area Touches`, `Pass Completion %`, `SCA`, `GCA`, and more.
     - Scaled all features using `StandardScaler` for uniformity.
  2. Dimensionality Reduction
    Applied **PCA (Principal Component Analysis)** o capture variance in 2–3 dimensions, enabling better visualization and noise reduction
  3.Clustering Algorithm
    - Used **K-Means** clustering to group similar players into distinct style-based categories.
  - Determined optimal cluster count using:
    - Elbow Method (for within-cluster variance)
    - Silhouette Score (for cluster separation)
  4. Labeling and Interpretation
    - Analyzed z-score averages of each cluster to assign descriptive tactical profiles like *Elite Creator* or *Pressing Forward*
  5. Visualization
    - *PCA Scatter Plot*: Each dot = 1 player, positioned by style and color-coded by cluster
    - *Cluster Heatmap*: Shows average z-scores across features per cluster to highlight strengths and traits

#### Cluster Legend:
| Cluster | Label                |
|---------|----------------------|
|   0     | Support Forward      |
|   1     | All-Around Attacker  |
|   2     | Elite Creator        |
|   3     | Link Play Forward    |
|   4     | Secondary Creator    |
|   5     | Dribbling Playmaker  |
|   6     | Pressing Forward     |
|   7     | Ball-Dominant Star   |
|   8     | Peripheral Forward   |

<details>
  <summary>
    <strong>Cluster Descriptions & Player Examples</strong>
  </summary>
  
| Cluster | Label                   | Description                                        | Sample Players                                  |
| ------: | :---------------------- | :------------------------------------------------- | :---------------------------------------------- |
|     `0` | **Support Forward**     | Decent xG, KP; moderate creativity; secondary role | *Sørloth, Lewandowski, Haaland, Mateta, Lukaku* |
|     `1` | **All-Around Attacker** | High xG, xA, GCA, KP, PrgP — complete profile      | *Mbappé, Kane, Ferrán Torres, Isak, Retegui*    |
|     `2` | **Elite Creator**       | Very high xA, xAG, KP — elite chance creation      | *Doku, Son, Saka, Lookman, Benrahma*            |
|     `3` | **Link Play Forward**   | Modest xG/xA; helps through buildup play           | *Gakpo, Eze, Mitoma, Zhegrova, Guessand*        |
|     `4` | **Secondary Creator**   | Balanced creator with supporting stats             | *Rashford, Zirkzee, Gabriel Jesus, Openda*      |
|     `5` | **Dribbling Playmaker** | Strong GCA, PrgP, PrgC — creates via movement      | *Kulusevski, Yıldız, Pulisic, Murphy*           |
|     `6` | **Pressing Forward**    | Low goal output; excels defensively                | *Iliman Ndiaye, McGinn, Merino, Weah*           |
|     `7` | **Ball-Dominant Star**  | High across the board — attacking hub              | *Yamal, Dembélé, Olise, Dybala, Cunha*          |
|     `8` | **Peripheral Forward**  | Low involvement — may be passive or isolated       | *Højlund, Füllkrug, Morata, Danjuma*            |
</details>


This analysis bridges data science and football tactics, offering scouts, analysts, and fans a tool to understand player roles through behavior rather than position labels.

  **Programming Language**: Python

  **Libraries**: `pandas`, `scikit-learn`, `matplotlib`, `seaborn`, `numpy`

📊 Use Cases:
    - Player Scouting & Recruitment
    - Tactical Planning
    - Finding Stylistic Replacements

---

### Player Skill Radar Charts (Pizza Plots)
[`pizza`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/pizza/radar.py)

[`bergvall (Tottenham)`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/pizza/bergvall_pizza.png)
[`kimmich (Bayern)`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/pizza/kimmich_pizza.png)
[`pedri (Barcelona)`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/pizza/pedri_pizza.png)
[`valverde (Real Madrid)`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/pizza/valverde_pizza.png)

This visualization presents soccer player skill profiles as radar (pizza) charts, allowing for easy comparison of player attributes across multiple performance metrics. Inspired by modern football analytics, these charts synthesize attacking, passing, and defensive stats into a single compact graphic.

Each radar chart shows normalized values (z-scores) for a selection of key performance indicators (per 90 minutes), including:
  - Key Passes
  - xA (Expected Assists)
  - Final ⅓ Passes
  - Penalty Area Passes (PPA)
  - Progressive Passes (PrgP)
  - Pass Completion %
  - Dribbles
  - Tackles Won
  - Progressive Carries
  - Shot-Creating Actions (SCA)
  - Goal-Creating Actions (GCA)
  - Ball Recoveries

These stats are drawn from Europe’s Big 5 Leagues during the 2024–25 season, and each player's values are standardized relative to others in their position group (e.g., midfielders vs forwards). This provides contextualized comparisons and surfaces player strengths clearly.

📊 Use Cases:
  - Scouting comparisons
  - Tactical fit assessment
  - Fan-facing visual storytelling
  - Player development profiling

**Programming Language**: Python

**Packages Used**: `pandas`, `matplotlib`, `mplsoccer`, `numpy`

---

### Progressive Passes per 90 vs Key Passes per 90 (24-25 Season Big 5 Leagues)
[`prog_vs_kp`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/worldfootballr/prog_vs_kp/prog.R)

[`plot`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/worldfootballr/prog_vs_kp/big5_prgp_vs_kp_top15.png)

This scatter plot visualizes **Progressive Passes per 90 vs. Key Passes per 90** to spotlight the most creative and influential passers across all positions in the 2024–25 season from Europe’s Big 5 Leagues.
  - **Progressive Passes (PrgP)** quantify how often a player moves the ball significantly forward toward the opponent’s goal, reflecting their role in buildup play, tempo control, and ball advancement through opposition lines.
  - **Key Passes (KP)** represent passes that directly lead to a shot, capturing the players who consistently create scoring opportunities for their teammates.

This visualization captures two key dimensions of creativity:
  - **High PrgP**: Often associated with **deep-lying playmakers**, press-resistant midfielders, or fullbacks who initiate attacks and help teams gain territory.
  - **High KP**: Typically seen in **advanced creators** — attacking midfielders, wingers, or forwards who provide the final ball before a shot.

Key Findings:
  - **Top 15 in Progressive Passes per 90**: *Bruno Fernandes, Joshua Kimmich, Pedri, Angelo Stiller, Rodrigo De Paul, Frenkie de Jong, Martin Ødegaard, Manuel Locatelli, Vitinha, Florian Tardieu, Dani Ceballos, Fabián Ruiz Peña, Iñigo Martínez, Granit Xhaka*
    - These players are pivotal in orchestrating play from deeper zones, progressing the ball with intent and precision.
  - **Top 15 in Key Passes per 90**: *Isco, Bukayo Saka, Raphinha, Arda Güler, Kevin Stöger, Junya Ito, Alex Baena, Lee Kang-in, Franck Honorat, Michael Olise, Kevin De Bruyne, Rayan Cherki, Ousmane Dembélé, Désiré Doué*
    - Elite playmakers in the final third — these players thrive in tight spaces, creating high-quality chances through incisive passing.
  - **Top 15 in Both Categories**: *Luka Modrić*
    - This select group excels at both advancing possession and generating shots, blending ball progression with end-product creativity — making them some of Europe’s most complete creators.

By comparing these two metrics, the plot reveals not just who racks up assists, but who drives creativity from all over the pitch — whether it's the pass before the assist, or the buildup that leads to goals.

**Programming Language**: R

**Packages Used**: `dplyr`, `ggplot2`, `readr`, `ggrepel`

---

### Passes into Penalty Area per 90 vs. Key Passes per 90 (24-25 Big 5 Leagues)
[`ppa_vs_kp`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/worldfootballr/ppa_vs_kp/mid.R)

[`all positions`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/worldfootballr/ppa_vs_kp/big5_ppa_vs_kp_top15.png)
[`forwards`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/worldfootballr/ppa_vs_kp/big5_ppa_vs_kp_top15_fw.png)
[`midfielders`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/worldfootballr/ppa_vs_kp/big5_ppa_vs_kp_top15_mf.png)
[`defenders`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/worldfootballr/ppa_vs_kp/big5_ppa_vs_kp_top15_df.png)

This scatter plot visualizes **Passes into Penalty Area per 90 vs. Key Passes per 90** s highlighting the most dangerous and creative distributors in the **2024-25 season across Europe’s Big 5 Leagues**.
  - **Passes into the Penalty Area (PPA)** measure how frequently a player delivers the ball into the 18-yard box. These are high-value entries often associated with attacking intent, wide play, and final-third dominance.
  - **Key Passes (KP)** are passes that directly lead to a shot, making them a strong indicator of chance creation and playmaking quality.
    
Players excelling in **Progressive Passes per 90** are key contributors to buildup play, often operating deeper or in transition. Those leading in **Key Passes per 90** tend to be final-third creators, delivering that crucial pass before a shot.

Key Findings (All Positions):
  - **Passes into Penalty Area per 90**: *Bruno Fernandes, Xavi Simons, Alex Iwobi, Antony, Lamine Yamal, Jermey Doku, Osame Sahraoui, Romano Schmid, Giovani Lo Celso, Martin Ødegaard*
    - These players frequently penetrate the opponent’s box with targeted delivery, often functioning as wide creators, attacking full-backs, or deep-lying playmakers.
  - **Top 15 in Key Passes per 90**: *Isco, Luka Modrić, Bukayo Saka, Raphinha, Arda Güler, Kevin Stöger, Junya Ito, Alex Baena, Lee Kang-in, Franck Honorat*
    - These players are elite chance creators. They often play advanced roles (e.g. attacking midfielders, wingers), thriving in tight spaces and delivering final balls.
  - **Top 15 in Both Categories**: *Michael Olise, Kevin De Bruyne, Rayan Cherki, Ousmane Dembélé, Désiré Doué*
    - These players combine volume and quality — not only finding teammates in the box but also setting up shots with regularity. They are among the most dangerous playmakers in Europe.

This plot helps identify players who don’t just progress the ball, but consistently break defensive lines and generate scoring opportunities through intelligent, incisive passing.

**Programming Language**: R

**Packages Used**: `dplyr`, `ggplot2`, `readr`, `ggrepel`

---

### Double Big Lineups: Advanced Metrics (2024-25 NBA Season)
[`two_man`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/double_bigs/two_man.R)

[`plot`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/double_bigs/double_big.png)

This **table** presents advanced metrics for **2-man frontcourt lineups**—duos consisting of two bigs (centers or power forwards)—from the **2024-25 NBA Regular Season**. It highlights how these lineups perform across categories like Net Rating, Offensive Rating, Defensive Rating, and minutes played.

Data is sourced from the NBA's official stats site using the `hoopR` package and formatted using `gt` and `gtExtras` for enhanced readability and insight.

**Metrics included**:
- **Net Rating**: Point differential per 100 possessions—measures overall effectiveness.  
- **Offensive/Defensive Ratings**: Points scored and allowed per 100 possessions, showing balance or strength on either end.  
- **Minutes Played**: Indicates how often the duo is used together on the floor.

This visual helps highlight the strategic use of size in the modern NBA—where rim protection, rebounding, and versatility remain crucial, even as spacing and pace evolve.

**Programming Language**: R  

**Packages Used**: `hoopR`, `dplyr`, `janitor`, `gt`, `gtExtras`, `webshot2`

---

### Successful Take-ons vs Shot Creating Actions (23-24 Big 5 Leagues)
[`takeons_vs_sca`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/worldfootballr/takeons_vs_sca/big_5_creative.R)

[`big 5`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/worldfootballr/takeons_vs_sca/big5_all_successful_takeons_vs_sca_top15.png)
[`prem`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/worldfootballr/takeons_vs_sca/successful_takeons_vs_sca_top15.png)

This scatter plot visualizes **Successful Take-Ons per 90 vs. Shot-Creating Actions (SCA) per 90** to highlight the most creative and dynamic players from the **2023-24 Big 5 European Leagues**.
  - **Successful take-ons** measure how often a player successfully dribbles past an opponent, showcasing their ability to beat defenders and drive play forward.
  - **Shot-creating actions (SCA)** track the two offensive actions leading to a shot, including passes, dribbles, fouls drawn, and defensive plays.

Players excelling in **SCA per 90** are among the most influential in their team’s attack, while those leading in **Successful Take-Ons per 90** are some of the league’s most dangerous ball carriers.

Key Findings:
  - **Top 15 in SCA per 90**: *Kevin Stöger, Kevin De Bruyne, James Maddison, Martin Ødegaard, Jonas Hofmann, Téji Savanier, Bruno Fernandex, Aleksei Miranchuk, Nadir Zortea, FLorian Wirtz, Isco, Romain Del Castillo*
    - These players are elite playmakers who consistently create scoring chances for their teammates, often through passing, crosses, and set-piece deliveries.
  - **Top 15 in Successful Take-Ons per 90**: *Edon Zhegrova, Khvicha Kvaratskhelia, Mohammed Kudus, Nico Williams, Mathys Tel, Jérémy Boga, Rayan Cherki, Brahim Diaz, Désiré Doué, Jamie Gittens, Brajan Gruda, Ilias Akhomach.*
    - These players are explosive dribblers who thrive in 1v1 situations, stretching defenses and destabilizing defensive structures. 
  - **Top 15 in Both Categories**: *Leroy Sané, Ousmane Dembélé, Jeremy Doku*
    - Players in this elite group are not only exceptional at carrying the ball past defenders but also among the most influential creators in attack.

This analysis helps identify the most dynamic and influential attackers across the Big 5 Leagues in Europe, offering insights beyond traditional goal and assist statistics.

**Programming Language**: R

**Packages Used**: `dplyr`, `ggplot2`, `readr`, `ggrepel`

---

### Leaderboard Plot
[`leaderboard_plot`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/leaderboard_plot/leaderboard.R)

[`plot`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/leaderboard_plot/defensive_stops_per100.png)

This chart displays a **facet-wrapped leaderboard** ranking the **top 50 NBA players** by **Defensive Stops Per 100 Possessions** (as of **March 20, 2025**). The data comes from [pbpstats.com](https://pbpstats.com), and I’ve filtered for players with at least **1,500 defensive possessions** to ensure a meaningful sample size. A **Defensive Stop** is calculated as: Steals + Recovered Blocks + Offensive Fouls Drawn + Charge Fouls Drawn And **Stops Per 100** is determined by: (Defensive Stops / Defensive Possessions) * 100. This stat provides a **broader measure of defensive impact** beyond traditional stats like **steals and blocks**, focusing on how effective a player is at **ending an opponent’s possession**. Many great defenders—like **Lu Dort and Draymond Green**—don’t accumulate high steals or blocks but still rank **inside the top 20** due to their ability to disrupt plays in other ways. **Guards** may not block many shots, but they excel in **steals, drawing charges, and recovering loose balls**. **Big men** might not generate steals but contribute with **blocks and contested rebounds**. The chart uses:**Custom borders** colored based on each team's **primary and alternate colors** and **Team logos** for added clarity  

**Programming Language**: R

**Packages Used**: `tidyverse`, `jsonlite`, `hoopR`, `ggimage`, `janitor`

---

### Diamond Plot
[`diamond_plot`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/diamond_plot/diamond_plot.R)

[`plot`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/diamond_plot/epa_diamond_plot.png)

The chart is a visual representation of NFL teams' offensive and defensive performance using Expected Points Added (EPA) per play for the 2024-2025 regular season. It loads in play-by-play data, filters relevant plays, and calculates average offensive and defensive EPA for each team. The data is then plotted on a rotated scatterplot, with teams positioned based on their offensive and defensive efficienct, and categorized into four performance quadrants ("Good O, Bad D"). The team logos are for added clarity and the plot is styled with color coded regions and customized labels.

**Programming Language**: R

**Packages Used**: `tidyverse`, `nflplotR`, `nflreadr`, `grid`, `ggtext`

---

### Hotspot Chart
[`hotspot`](https://github.com/danieloyasodun/nba-data-visualization/blob/main/hotspotchart/hotspot.R)


[`plot`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/hotspotchart/hotspot.R)

The charts show the areas of the court where the player prefers (and dislikes) to shoot from. It visualizes their shooting tendencies relative to league average. The darker and denser the red area the more frequently the players from that location. The gray areas represent spots where the player shoots less often than their peers, areas with no color indicate locations where player's shot selection aligns with the league average.

**Programming Language**: R

**Packages Used**: `tidyverse`, `devtools`, `duckdb`, `DBI`, `metR`, `ggtext`, `extrafont`, `ggnewscale`

---

### Computer Vision Football Analysis
[`football_analysis`](https://github.com/danieloyasodun/football_analysis)

This project aims to detect and track players, referees, and footballs in video using YOLO, a top AI object detection model, and improve its performance through training. Using K-means clustering to assign players to teams based on shirt colors, calculate ball possession percentage and track player movement with optical flow. Perspective transformation will convert movement from pixels to meters. Finally, we’ll calculate player speed and distance covered, addressing real-world challenges suitable for both beginners and experienced machine learning engineers.

**Programming Language**: Python

**Libraries/Frameworks**: `YOLO`, `OpenCV`, `K-means`, `Optical Flow`, `Perspective Transformation`
