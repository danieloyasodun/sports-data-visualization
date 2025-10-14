library(readr)
library(dplyr)
library(ggplot2)
library(glmnet)
library(ggrepel)

# Load data
nba <- read_csv("nba_2024_combined.csv")

# Keep numeric columns only (drop Team, Arena, attendance)
nba_num <- nba %>%
  select(-Team, -starts_with("Arena"), -starts_with("Attend")) %>%
  select(where(is.numeric)) %>%
  select_if(~ sd(.) > 0)

# Drop columns we don't want in model
ignore_cols <- c("W", "L", "PW", "PL", "PTS",
                 "PS_per_G", "PA_per_G", "MOV", "SRS", "GB", "WL_pct",
                 "ORtg", "DRtg", "NRtg", "Rk_per100", "Rk", "SOS",
                 "FG._shooting", "FGM", "Rk_shooting")
nba_num <- nba_num %>% select(-any_of(ignore_cols))

# Response
y <- nba$W
wins <- nba$W

# Predictor matrix for glmnet
X <- as.matrix(nba_num)

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

# alpha = 1 for Lasso
lasso_model <- cv.glmnet(X, y, alpha = 1, nfolds = 5)

# Best lambda (minimizes cross-validated MSE)
best_lambda <- lasso_model$lambda.min
best_lambda

# Coefficients at best lambda
coef(lasso_model, s = best_lambda)

lasso_coefs <- as.matrix(coef(lasso_model, s = best_lambda))
lasso_coefs <- lasso_coefs[-1, , drop = FALSE]  # remove intercept
feature_importance <- data.frame(
  stat = rownames(lasso_coefs),
  coefficient = as.numeric(lasso_coefs)
)

# Absolute value of coefficients for importance
feature_importance <- feature_importance %>%
  filter(coefficient != 0) %>%
  arrange(desc(abs(coefficient)))

ggplot(feature_importance, aes(x = reorder(stat, coefficient), y = coefficient, fill = coefficient > 0)) +
  geom_col() +
  coord_flip() +
  labs(title = "Lasso Feature Importance for Wins", y = "Coefficient", x = "Stat") +
  scale_fill_manual(values = c("TRUE" = "steelblue", "FALSE" = "tomato")) +
  theme_minimal()

ggsave("lasso.png", width = 10, height = 8, bg = "white")

predicted_wins <- predict(lasso_model, newx = X, s = best_lambda)
nba_results <- data.frame(
  Team = nba$Team,
  actual_wins = y,
  predicted_wins = as.numeric(predicted_wins)
)

write_csv(nba_results, "nba_actual_vs_predicted_wins_lasso.csv")

# Add a column to flag over/under performing teams
nba_results <- nba_results %>%
  mutate(
    performance = case_when(
      actual_wins > predicted_wins ~ "Over-performed",
      actual_wins < predicted_wins ~ "Under-performed",
      TRUE ~ "As predicted"
    )
  )

# Plot
ggplot(nba_results, aes(x = actual_wins, y = predicted_wins, color = performance)) +
  geom_point(size = 3) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "black", size = 1) +
  geom_text_repel(aes(label = Team), size = 2.5, max.overlaps = Inf) +
  scale_color_manual(values = c(
    "Over-performed" = "forestgreen",
    "Under-performed" = "tomato",
    "As predicted" = "steelblue"
  )) +
  labs(
    title = "Actual vs Predicted Wins (Lasso Model)",
    x = "Actual Wins",
    y = "Predicted Wins",
    color = "Performance"
  ) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )

# Save plot
ggsave("actual_vs_predicted_wins_lasso_colored.png", width = 10, height = 8, bg = "white")