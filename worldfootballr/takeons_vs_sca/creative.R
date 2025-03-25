library(dplyr)
library(ggplot2)
library(readr)

# Folder path
data_folder <- "prem_2024_data/"

# Load the relevant columns from each dataset
possession_data <- read_csv(file.path(data_folder, "prem_2024_possession.csv")) %>%
  select(Player, Succ_Take_minus_Ons, Pos)  # Just the relevant columns

gca_data <- read_csv(file.path(data_folder, "prem_2024_gca.csv")) %>%
  select(Player, SCA90_SCA)

playing_time_data <- read_csv(file.path(data_folder, "prem_2024_playing_time.csv")) %>%
  select(Player, `Min_Playing Time`)

# Merge the data based on player name
merged_data <- possession_data %>%
  inner_join(gca_data, by = "Player") %>%
  inner_join(playing_time_data, by = "Player")

# Calculate successful take-ons per 90 (Succ_Take_minus_Ons / Min_Playing Time * 90)
merged_data <- merged_data %>%
  mutate(
    Succ_Take_Per_90 = (Succ_Take_minus_Ons / `Min_Playing Time`) * 90,
    SCA_Per_90 = SCA90_SCA
  )

# Drop players with more than one entry (grouped by player)
merged_data <- merged_data %>%
  group_by(Player) %>%
  filter(n() == 1) %>%
  ungroup()

# Filtering for forwards and midfielders, and players with more than 500 minutes
forwards_midfielders <- merged_data %>%
  filter(Pos %in% c("FW", "MF")) %>%
  filter(SCA_Per_90 > 0) %>%
  filter(`Min_Playing Time` > 500)

# Get the top 5 players based on SCA_Per_90
top_5_sca <- forwards_midfielders %>%
  arrange(desc(SCA_Per_90)) %>%
  head(5)

# Get the top 5 players based on Succ_Take_Per_90 (Successful Dribbles)
top_5_dribbles <- forwards_midfielders %>%
  arrange(desc(Succ_Take_Per_90)) %>%
  head(5)

# Add a new variable to classify players into different categories
forwards_midfielders <- forwards_midfielders %>%
  mutate(
    Player_Type = case_when(
      Player %in% top_5_sca$Player & Player %in% top_5_dribbles$Player ~ "Top 5 Both",
      Player %in% top_5_sca$Player ~ "Top 5 SCA",
      Player %in% top_5_dribbles$Player ~ "Top 5 Dribbles",
      TRUE ~ "Others"
    )
  )

# Create the scatter plot
plot <- ggplot(forwards_midfielders, aes(x = Succ_Take_Per_90, y = SCA_Per_90)) +  
  geom_point(aes(color = Player_Type), size = 3) + 
  geom_text(data = top_5_sca, aes(label = Player), vjust = -0.5, hjust = 1.2, color = "black") +  # Labels for top 5 SCA players
  geom_text(data = top_5_dribbles, aes(label = Player), vjust = -0.5, hjust = 1.2, color = "black") +  # Labels for top 5 Dribbles players
  labs(
    title = "Successful Take-Ons per 90 vs SCA per 90 (23-24 Seaason Premier League)",
    x = "Successful Take-Ons per 90",
    y = "SCA (Shot-Creating Actions) per 90",
    color = "Player Type",
    size = "Minutes per 90",
    caption = "Only players with more than 500 minutes played are displayed"
  ) +
  scale_color_manual(values = c(
    "Top 5 Both" = "purple", 
    "Top 5 SCA" = "red", 
    "Top 5 Dribbles" = "blue", 
    "Others" = "gray"
  )) +  # Change color for different categories
  theme_minimal() +
  theme(
    legend.position = "bottom",
    panel.background = element_rect(fill = "lightblue"),
    plot.background = element_rect(fill = "white")
  )

# Save the plot as a PNG image
ggsave("successful_takeons_vs_sca_top5_combined.png", plot = plot, width = 10, height = 6)