library(dplyr)
library(worldfootballR)

prem_2024_player_shooting <- fb_league_stats(
  country = "ENG",
  gender = "M",
  season_end_year = 2024,
  tier = "1st",
  non_dom_league_url = NA,
  stat_type = "keepers_adv",
  team_or_player = "player"
)

write.csv(prem_2024_player_shooting, "prem_2024_keepers_adv.csv", row.names = FALSE)