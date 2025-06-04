library(dplyr)
library(ggplot2)
library(readr)
library(ggrepel)

# Folder path
data_folder <- "big5_2025_player_data"

# Load the relevant columns from each dataset
passing_data <- read_csv(file.path(data_folder, "big5_player_passing_2025.csv")) %>%
  select(Player, KP, Pos, PrgP)  # Just the relevant columns

# Load and filter playing time data for players with more than 1000 minutes before merging
playing_time_data <- read_csv(file.path(data_folder, "big5_player_playing_time_2025.csv")) %>%
  filter(Min_Playing.Time > 1000) %>%  # Apply filter here
  select(Player, Min_Playing.Time)

# Merge the data based on player name
merged_data <- passing_data %>%
  inner_join(playing_time_data, by = "Player")

# Calculate successful take-ons per 90 (Succ_Take_minus_Ons / Min_Playing Time * 90)
merged_data <- merged_data %>%
  mutate(
    PrgP_per_90 = (PrgP / Min_Playing.Time) * 90,
    KP_per_90 = (KP / Min_Playing.Time) * 90
  )

# Drop duplicate players with more than one entry (grouped by player)
merged_data <- merged_data %>%
  group_by(Player) %>%
  slice_max(Min_Playing.Time, n = 1) %>%
  ungroup()

# Filtering for forwards and midfielders, and players with more than 1000 minutes
filtered_data <- merged_data %>%
  filter(PrgP_per_90 > 0) %>%
  filter(Min_Playing.Time > 1000)

top_ppa <- filtered_data %>% arrange(desc(PrgP_per_90)) %>% head(15)
top_kp <- filtered_data %>% arrange(desc(KP_per_90)) %>% head(15)

# Categorize player types
filtered_data <- filtered_data %>%
  mutate(
    Player_Type = case_when(
      Player %in% top_ppa$Player & Player %in% top_kp$Player ~ "Top 15 Both",
      Player %in% top_ppa$Player ~ "Top 15 PrgP",
      Player %in% top_kp$Player ~ "Top 15 KP",
      TRUE ~ "Others"
    )
  )

top_15_players <- bind_rows(top_ppa, top_kp) %>%
  distinct(Player, .keep_all = TRUE)

# Plot
plot <- ggplot(filtered_data, aes(x = PrgP_per_90, y = KP_per_90)) +
  geom_point(aes(color = Player_Type), size = 2) +
  geom_text_repel(data = top_15_players, aes(label = Player), 
                  color = "black", size = 3, box.padding = 0.5, max.overlaps = 10) +
  labs(
    title = "Progressive Passes per 90 vs. Key Passes per 90 (24-25 Season Big 5 Leagues)",
    x = "Progressive Passes per 90",
    y = "Key Passes per 90",
    color = "Player Type",
    caption = "Only players with more than 1000 minutes played are displayed"
  ) +
  scale_color_manual(values = c(
    "Top 15 Both" = "purple", 
    "Top 15 PrgP" = "dodgerblue", 
    "Top 15 KP" = "lightcoral", 
    "Others" = "gray"
  )) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    panel.background = element_rect(fill = "lightblue"),
    plot.background = element_rect(fill = "white")
  )

# Save plot
ggsave("big5_prgp_vs_kp_top15.png", plot = plot, width = 10, height = 6)