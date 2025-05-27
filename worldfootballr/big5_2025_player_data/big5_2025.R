library(dplyr)
library(worldfootballR)

big5_player_shooting <- fb_big5_advanced_season_stats(
    season_end_year= 2025, 
    stat_type= "keepers_adv", 
    team_or_player= "player"
)

write.csv(big5_player_shooting, "big5_player_keepers_adv_2025.csv", row.names = FALSE)