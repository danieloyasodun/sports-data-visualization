library(readr)
library(dplyr)
library(ggplot2)
library(stringr)

# Load data
nba <- read_csv("nba_2024_combined.csv")

# Use cleaned numeric columns
nba_num <- nba %>%
  select(-Team, -starts_with("Arena"), -starts_with("Attend")) %>%
  select(where(is.numeric)) %>%
  select_if(~ sd(.) > 0)

# Drop columns we want to ignore
ignore_cols <- c("W", "L", "PW", "PL", "PTS",
                 "PS_per_G", "PA_per_G", "MOV", "SRS", "GB", "WL_pct",
                 "ORtg", "DRtg", "NRtg", "Rk_per100", "Rk", "SOS",
                 "FG._shooting", "FGM", "Rk_shooting")
nba_num <- nba_num %>% select(-any_of(ignore_cols))

# Response variable
wins <- nba$W

# ---- Correlation analysis ----
cor_results <- nba_num %>%
  summarise(across(everything(), ~ cor(.x, wins, use = "complete.obs"))) %>%
  tidyr::pivot_longer(everything(), names_to = "stat", values_to = "correlation") %>%
  arrange(desc(abs(correlation)))

print(head(cor_results, 20))

# ---- Plot top correlations ----
p <- cor_results %>%
  top_n(20, abs(correlation)) %>%
  ggplot(aes(x = reorder(stat, correlation), y = correlation, fill = correlation > 0)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 20 Stats Correlated with Team Wins (2024-25 Season)",
    x = "Statistic",
    y = "Correlation with Wins"
  ) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  ) +
  scale_fill_manual(values = c("TRUE" = "steelblue", "FALSE" = "tomato"))

ggsave("top20_win_correlations.png", plot = p, width = 8, height = 6, bg = "white")

# Pick top 10 correlated stats
top_vars <- cor_results %>%
  slice_max(abs(correlation), n = 10) %>%
  pull(stat)

# Backtick all variable names to handle %, spaces, etc.
top_vars_backtick <- paste0("`", top_vars, "`")

# Build formula
formula <- as.formula(paste("wins ~", paste(top_vars_backtick, collapse = " + ")))

# Fit linear model
lm_model <- lm(formula, data = nba_num)
summary(lm_model)

# Stepwise selection
lm_step <- step(lm_model, direction = "both", trace = 1)

# Summary of final model
summary(lm_step)

library(ggrepel)

# ---- Actual vs Predicted Wins Plot with Team Labels ----
nba_predictions <- nba_num %>%
  mutate(
    predicted_wins = predict(lm_step, newdata = nba_num),
    actual_wins = wins,
    Team = nba$Team  # add the team names
  )

ggplot(nba_predictions, aes(x = actual_wins, y = predicted_wins)) +
  geom_point(color = "steelblue", size = 3) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red", size = 1) +
  geom_text_repel(aes(label = Team), size = 3.5) +
  labs(
    title = "Actual vs Predicted Wins",
    x = "Actual Wins",
    y = "Predicted Wins"
  ) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )

nba_predictions %>%
  select(Team, actual_wins, predicted_wins) %>%
  write_csv("nba_actual_vs_predicted_wins.csv")

# Save plot
ggsave("actual_vs_predicted_wins_labeled.png", width = 10, height = 8, bg = "white")

# ---- Save linear model summaries ----
# LM summary
lm_summary_file <- "lm_model_summary.txt"
sink(lm_summary_file)
print(summary(lm_model))
sink()  # reset output

# Stepwise model summary
lm_step_summary_file <- "lm_step_model_summary.txt"
sink(lm_step_summary_file)
print(summary(lm_step))
sink()  # reset output
