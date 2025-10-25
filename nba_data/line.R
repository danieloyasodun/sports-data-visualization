library(tidyverse)
library(ggimage)
library(janitor)
library(hoopR)

# Load CSV of team wins/losses
df <- read_csv("team_win_loss_by_season.csv") %>%
  clean_names()

# Define conferences
east_teams <- c("ATL", "BOS", "BKN", "CHA", "CHI", "CLE", "DET", 
                "IND", "MIA", "MIL", "NYK", "ORL", "PHI", "TOR", "WAS")
west_teams <- c("DAL", "DEN", "GSW", "HOU", "LAC", "LAL", "MEM",
                "MIN", "NOP", "OKC", "PHX", "POR", "SAC", "SAS", "UTA")

df <- df %>%
  mutate(conference = if_else(team %in% east_teams, "East", "West"))

team_lookup <- nba_teams() %>%
  transmute(team_abbreviation,
            logo = nba_logo_svg,  # svg or png
            color = paste0("#", color))

df <- df %>%
  left_join(team_lookup, by = c("team" = "team_abbreviation"))

library(ggplot2)

# Find max wins to set a little extra space
max_wins <- max(df$wins, na.rm = TRUE)

p <- ggplot(df, aes(x = season, y = wins, group = team, color = team)) +
  geom_line(size = 1.5) +
  geom_image(
    aes(image = logo),
    data = df %>% group_by(team) %>% slice_tail(n = 1),
    size = 0.05
  ) +
  scale_color_manual(values = setNames(df$color, df$team)) +
  facet_wrap(~conference) +
  labs(
    title = "NBA Team Wins by Season",
    subtitle = "Season column represents start year of the season",
    x = "Season (start year)", y = "Wins"
  ) +
  theme_minimal() +
  expand_limits(y = max_wins + 5)  # <-- adds extra space above top line

ggsave("nba_team_wins.png", plot = p, width = 12, height = 6, dpi = 300, bg = "white")