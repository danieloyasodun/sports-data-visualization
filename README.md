## Sports Analytics: Uncovering Insights Through Data

### Description
This repository is a collection of projects and experiments where I practice and learn data visualization using R and Python. I explore NBA stats and play-by-play data from [here](https://github.com/shufinskiy/nba_data) to create visualizations, inclusing shot charts, heatmaps and other anlytical graphics. The goal is to develope a deeper understanding of data story telling and sports analytics.

---

### Double Big Lineups: Advanced Metrics (2024-25 NBA Season)
[`two_man`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/double_bigs/two_man.R)

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

This chart displays a **facet-wrapped leaderboard** ranking the **top 50 NBA players** by **Defensive Stops Per 100 Possessions** (as of **March 20, 2025**). The data comes from [pbpstats.com](https://pbpstats.com), and I’ve filtered for players with at least **1,500 defensive possessions** to ensure a meaningful sample size. A **Defensive Stop** is calculated as: Steals + Recovered Blocks + Offensive Fouls Drawn + Charge Fouls Drawn And **Stops Per 100** is determined by: (Defensive Stops / Defensive Possessions) * 100. This stat provides a **broader measure of defensive impact** beyond traditional stats like **steals and blocks**, focusing on how effective a player is at **ending an opponent’s possession**. Many great defenders—like **Lu Dort and Draymond Green**—don’t accumulate high steals or blocks but still rank **inside the top 20** due to their ability to disrupt plays in other ways. **Guards** may not block many shots, but they excel in **steals, drawing charges, and recovering loose balls**. **Big men** might not generate steals but contribute with **blocks and contested rebounds**. The chart uses:**Custom borders** colored based on each team's **primary and alternate colors** and **Team logos** for added clarity  

**Programming Language**: R
**Packages Used**: `tidyverse`, `jsonlite`, `hoopR`, `ggimage`, `janitor`

---

### Diamond Plot
[`diamond_plot`](https://github.com/danieloyasodun/sports-data-visualization/blob/main/diamond_plot/diamond_plot.R)

The chart is a visual representation of NFL teams' offensive and defensive performance using Expected Points Added (EPA) per play for the 2024-2025 regular season. It loads in play-by-play data, filters relevant plays, and calculates average offensive and defensive EPA for each team. The data is then plotted on a rotated scatterplot, with teams positioned based on their offensive and defensive efficienct, and categorized into four performance quadrants ("Good O, Bad D"). The team logos are for added clarity and the plot is styled with color coded regions and customized labels.

**Programming Language**: R
**Packages Used**: `tidyverse`, `nflplotR`, `nflreadr`, `grid`, `ggtext`

---

### Hotspot Chart
[`hotspot`](https://github.com/danieloyasodun/nba-data-visualization/blob/main/hotspotchart/hotspot.R)

The charts show the areas of the court where the player prefers (and dislikes) to shoot from. It visualizes their shooting tendencies relative to league average. The darker and denser the red area the more frequently the players from that location. The gray areas represent spots where the player shoots less often than their peers, areas with no color indicate locations where player's shot selection aligns with the league average.

**Programming Language**: R
**Packages Used**: `tidyverse`, `devtools`, `duckdb`, `DBI`, `metR`, `ggtext`, `extrafont`, `ggnewscale`

---

### Computer Vision Football Analysis
[`football_analysis`](https://github.com/danieloyasodun/football_analysis)

This project aims to detect and track players, referees, and footballs in video using YOLO, a top AI object detection model, and improve its performance through training. Using K-means clustering to assign players to teams based on shirt colors, calculate ball possession percentage and track player movement with optical flow. Perspective transformation will convert movement from pixels to meters. Finally, we’ll calculate player speed and distance covered, addressing real-world challenges suitable for both beginners and experienced machine learning engineers.

**Programming Language**: Python
**Libraries/Frameworks**: YOLO, OpenCV, K-means, Optical Flow, Perspective Transformation
