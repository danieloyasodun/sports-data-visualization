library(readr)
library(dplyr)
library(stringr)
library(tibble)

# Read CSVs
per100 <- read_csv("per_100_2024_teams.csv", show_col_types = FALSE)
shooting <- read_csv("shooting_stats_2024_teams.csv", show_col_types = FALSE)
advanced <- read_csv("advanced_2024_teams.csv", show_col_types = FALSE)

# Clean up team names
clean_team <- function(x) {
  gsub("\\*", "", trimws(x))
}

per100 <- per100 |> mutate(Team = clean_team(Team))
shooting <- shooting |> mutate(Team = clean_team(Team))
advanced <- advanced |> mutate(Team = clean_team(Team))

# Join all three
nba <- per100 |>
  left_join(shooting, by = "Team", suffix = c("_per100", "_shooting")) |>
  left_join(advanced, by = "Team", suffix = c("", "_advanced"))

# Add standings
standings <- tribble(
  ~Team, ~W, ~L, ~WL_pct, ~GB, ~PS_per_G, ~PA_per_G, ~SRS,
  "Cleveland Cavaliers", 64, 18, 0.780, 0.0, 121.9, 112.4, 8.81,
  "Boston Celtics", 61, 21, 0.744, 3.0, 116.3, 107.2, 8.28,
  "New York Knicks", 51, 31, 0.622, 13.0, 115.8, 111.7, 3.59,
  "Indiana Pacers", 50, 32, 0.610, 14.0, 117.4, 115.1, 1.68,
  "Milwaukee Bucks", 48, 34, 0.585, 16.0, 115.5, 113.0, 2.12,
  "Detroit Pistons", 44, 38, 0.537, 20.0, 115.5, 113.6, 1.73,
  "Orlando Magic", 41, 41, 0.500, 23.0, 105.4, 105.5, -0.70,
  "Atlanta Hawks", 40, 42, 0.488, 24.0, 118.2, 119.3, -1.41,
  "Chicago Bulls", 39, 43, 0.476, 25.0, 117.8, 119.4, -1.83,
  "Miami Heat", 37, 45, 0.451, 27.0, 110.6, 110.0, 0.11,
  "Toronto Raptors", 30, 52, 0.366, 34.0, 110.9, 115.2, -4.40,
  "Brooklyn Nets", 26, 56, 0.317, 38.0, 105.1, 112.2, -6.95,
  "Philadelphia 76ers", 24, 58, 0.293, 40.0, 109.6, 115.8, -6.29,
  "Charlotte Hornets", 19, 63, 0.232, 45.0, 105.1, 114.2, -9.10,
  "Washington Wizards", 18, 64, 0.220, 46.0, 108.0, 120.4, -12.14,
  "Oklahoma City Thunder", 68, 14, 0.829, 0.0, 120.5, 107.6, 12.70,
  "Houston Rockets", 52, 30, 0.634, 16.0, 114.3, 109.8, 4.97,
  "Los Angeles Lakers", 50, 32, 0.610, 18.0, 113.4, 112.2, 1.45,
  "Denver Nuggets", 50, 32, 0.610, 18.0, 120.8, 116.9, 3.97,
  "Los Angeles Clippers", 50, 32, 0.610, 18.0, 112.9, 108.2, 4.84,
  "Minnesota Timberwolves", 49, 33, 0.598, 19.0, 114.3, 109.3, 5.15,
  "Golden State Warriors", 48, 34, 0.585, 20.0, 113.8, 110.5, 3.56,
  "Memphis Grizzlies", 48, 34, 0.585, 20.0, 121.7, 116.9, 4.79,
  "Sacramento Kings", 40, 42, 0.488, 28.0, 115.7, 115.3, 0.58,
  "Dallas Mavericks", 39, 43, 0.476, 29.0, 114.2, 115.4, -0.74,
  "Phoenix Suns", 36, 46, 0.439, 32.0, 113.6, 116.6, -2.55,
  "Portland Trail Blazers", 36, 46, 0.439, 32.0, 110.9, 113.9, -2.67,
  "San Antonio Spurs", 34, 48, 0.415, 34.0, 113.9, 116.7, -2.45,
  "New Orleans Pelicans", 21, 61, 0.256, 47.0, 109.8, 119.3, -8.59,
  "Utah Jazz", 17, 65, 0.207, 51.0, 111.9, 121.2, -8.51
)

nba <- nba |> select(-any_of(c("W", "L", "SRS")))
nba_full <- nba |> left_join(standings, by = "Team")

nba_clean <- nba_full %>%
  select(-starts_with("...")) %>%                    # remove ... columns
  rename_with(~ make.names(., unique = TRUE)) %>%    # force unique names first
  rename_with(~ str_replace_all(., "\\.x$|\\.y$", ""))

write.csv(nba_clean, "nba_2024_combined.csv", row.names = FALSE)
