library(dplyr)
library(worldfootballR)

# Define the countries representing the big 5 leagues
big5_countries <- c("ENG", "ESP", "ITA", "GER", "FRA")

# Get team shooting stats for the 2020 season (i.e., 2019/2020)
big5_2025 <- fb_season_team_stats(country = big5_countries,
                                            gender = "M",
                                            season_end_year = 2025,
                                            tier = "1st",
                                            stat_type = "passing_types")

write.csv(big5_2025, "big5_team_passing_types_2025.csv", row.names = FALSE)
