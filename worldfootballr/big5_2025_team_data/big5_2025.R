library(dplyr)
library(worldfootballR)

big5_team_shooting <- fb_big5_advanced_season_stats(
    season_end_year=2025, 
    stat_type= "keepers_adv", 
    team_or_player= "team")
dplyr::glimpse(big5_team_shooting)

write.csv(big5_2025_shooting, "big5_team_keepers_adv_2025.csv", row.names = FALSE)
