library(tidyverse)
library(jsonlite)
library(hoopR)
library(ggimage)
library(janitor)

# custom ggplot2 theme
theme_f5 <- function (font_size = 9) { 
  theme_minimal(base_size = font_size, base_family = "Roboto") %+replace% 
    theme(
      plot.background = element_rect(fill = "floralwhite", color = "floralwhite"), 
      panel.grid.minor = element_blank(), 
      plot.title = element_text(hjust = 0, size = 14, face = 'bold'), 
      plot.subtitle = element_text(color = 'gray65', hjust = 0, margin=margin(2.5,0,10,0), size = 11), 
      plot.caption = element_text(color = 'gray65', margin=margin(-5,0,0,0), hjust = 1, size = 6)
    )
}

# create team lookup table
team_lookup <- nba_teams() %>% 
  transmute(team_abbreviation,
            nba_logo_svg,
            color = paste0("#", color),
            alternate_color = paste0("#", alternate_color))


url <- "https://api.pbpstats.com/get-totals/nba?Season=2024-25&SeasonType=Regular%2BSeason&Type=Player"

x <- fromJSON(url)
df <- x$multi_row_table_data

df <- df %>% clean_names()

df <- df %>% 
  select(name, team_abbreviation, def_poss, steals, recovered_blocks, offensive_fouls_drawn, charge_fouls_drawn) %>%
  mutate(across(def_poss:charge_fouls_drawn, ~ replace_na(., 0))) %>% 
  mutate(stops = steals + recovered_blocks + offensive_fouls_drawn + charge_fouls_drawn) %>% 
  mutate(stop_per100 = stops / def_poss * 100) %>% 
  filter(def_poss >= 1500) %>% 
  arrange(desc(stop_per100)) %>% 
  filter(row_number() <= 50)

df <- df %>% 
  mutate(cn = (row_number() - 1) %/% 10 + 1) %>% 
  group_by(cn) %>%
  mutate(rn = row_number()) %>% 
  ungroup()

df <- df %>% 
  left_join(., team_lookup, by = c("team_abbreviation"))

df <- df %>% 
  mutate(rank = paste0(row_number(), ".")) 

p <- df %>% 
  ggplot(aes(x = 1, y = 1)) + 
  scale_x_continuous(limits = c(.9, 1.1), expand = c(0,0)) + 
  scale_y_continuous(limits = c(.9, 1.05)) + 
  facet_wrap(rn~cn, ncol = 5) + 
  coord_cartesian(clip = 'off') + 
  theme_f5() +
  theme(axis.text = element_blank(), 
        strip.text = element_blank(), 
        panel.grid = element_blank(), 
        axis.title = element_blank())  +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, color = color), fill = 'transparent', linewidth = 1) + 
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, color = alternate_color), fill = 'transparent', linewidth = .35)  +
  scale_color_identity() +
  geom_text(aes(x = .925, y = .975, label = rank), size = 3, hjust = 1, family = "Roboto") + 
  geom_text(aes(x = .955, label = word(name, 1)), size = 2.5, hjust = 0, family = "Roboto") +
  geom_text(aes(x = .955, label = word(name, -1)), size = 2.5, vjust = 2, hjust = 0, family = "Roboto") + 
  geom_text(aes(x = 1.090, y = .975, label = sprintf("%.2f",stop_per100)), size = 3, hjust = 1, family = "Roboto") +
  geom_image(aes(x = .9375, y = .975, image = nba_logo_svg), size = .75) +
  labs(title = "Top 50 Players in Defensive Stops Per 100", 
       subtitle = "A defensive stop is a steal, block recovered by the defense, or a drawn offensive foul") 

ggsave("defensive_stops_per100.png", p, w = 8, h = 4, dpi = 600)