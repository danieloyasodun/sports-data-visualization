# Load packages
library(tidyverse) # for data wrangling
library(glue) # for pasting strings together
library(jsonlite) # for getting data from the web
library(httr) # for getting data from the web
library(janitor) # for cleaning column names
library(hablar) # for reclassifying data
library(hoopR) # for nba team ids
library(paletteer) # for colors
library(gt) # for making tables
library(gtExtras) # for making better tables
library(gtUtils) # for making even better tables

# read in NBA positions from my GitHub 
nba_positions <- read.csv("https://raw.githubusercontent.com/Henryjean/data/refs/heads/main/nba_positions.csv")

# get all 30 NBA teams from the hoopR package
nba_teams <- nba_teams()

# Set headers
headers = c(
  `Connection` = 'keep-alive',
  `Accept` = 'application/json, text/plain, */*',
  `x-nba-stats-token` = 'true',
  `X-NewRelic-ID` = 'VQECWF5UChAHUlNTBwgBVw==',
  `User-Agent` = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36',
  `x-nba-stats-origin` = 'stats',
  `Sec-Fetch-Site` = 'same-origin',
  `Sec-Fetch-Mode` = 'cors',
  `Referer` = 'https://stats.nba.com/players/leaguedashplayerbiostats/',
  `Accept-Encoding` = 'gzip, deflate, br',
  `Accept-Language` = 'en-US,en;q=0.9'
)

get_data <- function(teamid) {
  Sys.sleep(2)
  url <- glue("https://stats.nba.com/stats/leaguedashlineups?Conference=&DateFrom=&DateTo=&Division=&GameSegment=&GroupQuantity=2&ISTRound=&LastNGames=0&LeagueID=00&Location=&MeasureType=Advanced&Month=0&OpponentTeamID=0&Outcome=&PORound=0&PaceAdjust=N&PerMode=PerGame&Period=0&PlusMinus=N&Rank=N&Season=2024-25&SeasonSegment=&SeasonType=Regular%20Season&ShotClockRange=&TeamID={teamid}&VsConference=&VsDivision=")
  
  res <- GET(url = url, add_headers(.headers=headers))
  json_resp <- fromJSON(content(res, "text"))
  df <- data.frame(json_resp$resultSets$rowSet)
  
  colnames(df) <- json_resp[["resultSets"]][["headers"]][[1]]
  
  # clean variable names and reclassify column types
  df <- df %>% clean_names() %>% retype()
  
  return(df)
  
}

dat <- map_df(nba_teams$team_id, get_data)
dat %>% glimpse()

df <- dat %>% 
  # select relevant variables
  select(team_id, team_abbreviation, group_id, group_name, min, off_rating, def_rating, net_rating) %>%
  # separate group_id into individual playerIds
  separate(
    col = group_id,
    into = c("leading_dash", "player1_id", "player2_id", "trailing_dash"),
    sep = "-",          
    convert = TRUE
  ) %>%
  # remove irrelevant columns
  select(-leading_dash, -trailing_dash) %>%
  # separate group_name into individual player naers
  separate(
    col = group_name,
    into = c("player1_name", "player2_name"),
    sep = " - ",        
    remove = TRUE      
  ) 

# join in player positions 
df <- df %>% 
  # add player1's position
  left_join(., nba_positions, by = c("player1_id" = "nba_id")) %>% 
  rename(player1_pos = pos) %>% 
  # add player2's position
  left_join(., nba_positions, by = c("player2_id" = "nba_id")) %>% 
  rename(player2_pos = pos) %>%
  # look at combos where both players are "Centers"
  filter(player1_pos == "Center" & player2_pos == "Center") %>%
  # select relevant variables
  select(team_abbreviation, player1_id, player2_id, player1_name, player2_name, min, off_rating, def_rating, net_rating) %>% 
  # select each teams most used double big lineup by minutes played
  group_by(team_abbreviation) %>%
  slice_max(order_by = min, n = 1) %>%
  ungroup() %>%
  # minimum 125 MP
  filter(min >= 125) %>%
  # order by net rating
  arrange(desc(net_rating)) 

# add team logos
df <- df %>% 
  mutate(team_abbreviation = paste0("https://raw.githubusercontent.com/Henryjean/data/refs/heads/main/square_nba_logos/", team_abbreviation, ".svg"))

gt_theme_f5 <- function(gt_object, ...) {
  
  gt_object %>%
    opt_table_font(
      font = list(
        google_font("Roboto"),
        default_fonts()
      ),
      weight = 400
    ) %>%
    tab_style(
      locations = cells_title("title"),
      style = cell_text(
        font = google_font("Roboto"),
        weight = 700
      )
    ) %>%
    tab_style(
      locations = cells_title("subtitle"),
      style = cell_text(
        font = google_font("Roboto"),
        color = "gray65",
        weight = 400
      )
    ) %>%
    tab_style(
      style = list(
        cell_borders(
          sides = "top", color = "black", weight = px(0)
        ),
        cell_text(
          font = google_font("Roboto"),
          #transform = "uppercase",
          v_align = "bottom",
          size = px(14),
          weight = 'bold'
        )
      ),
      locations = list(
        gt::cells_column_labels(),
        gt::cells_stubhead()
      )
    ) %>%
    tab_options(
      column_labels.background.color = "floralwhite",
      data_row.padding = px(7.5),
      heading.border.bottom.style = "none",
      table.border.top.style = "none", # transparent
      table.border.bottom.style = "none",
      column_labels.font.weight = "bold", 
      column_labels.border.top.style = "none",
      column_labels.border.bottom.width = px(2),
      column_labels.border.bottom.color = "black",
      row_group.border.top.style = "none",
      row_group.border.top.color = "black",
      row_group.border.bottom.width = px(1),
      row_group.border.bottom.color = "floralwhite",
      stub.border.color = "floralwhite",
      stub.border.width = px(0),
      source_notes.font.size = 12,
      source_notes.border.lr.style = "none",
      table.font.size = 16,
      heading.align = "left",
      table.background.color = "floralwhite",
      table_body.hlines.color = 'gray90',
      ...
    )
}

# start basic
df %>% 
  gt() %>%
  gt_theme_f5() 

# add team logos
df %>% 
  gt() %>%
  gt_theme_f5() %>% 
  gt_img_rows(columns = team_abbreviation, height = 30, "web") %>% 
  cols_hide(columns = c(player1_id, player2_id))

# merge and stack player names
df %>% 
  gt() %>%
  gt_theme_f5() %>% 
  gt_img_rows(columns = team_abbreviation, height = 30, "web") %>% 
  cols_hide(columns = c(player1_id, player2_id)) %>%
  gt_merge_stack(col1 = player1_name, col2 = player2_name, 
                 font_size = c("14px", "14px"), 
                 font_weight = c("bold", "bold"), 
                 small_cap = F,
                 palette = c("black", "gray")) 

# add title and rename columns
df %>% 
  gt() %>%
  gt_theme_f5() %>% 
  gt_img_rows(columns = team_abbreviation, height = 30, "web") %>% 
  cols_hide(columns = c(player1_id, player2_id)) %>%
  gt_merge_stack(col1 = player1_name, col2 = player2_name, 
                 font_size = c("14px", "14px"), 
                 font_weight = c("bold", "bold"), 
                 small_cap = F,
                 palette = c("black", "gray"))  %>% 
  tab_header(title = "Doubling Up", 
             subtitle = "Net Rating of commonly used double big looks") %>%
  cols_label(team_abbreviation = "", 
             player1_name = "Big Combo", 
             min = "Min", 
             off_rating = md("Off.<br>Rating"), 
             def_rating = md("Def.<br>Rating"), 
             net_rating = md("Net<br>Rating")) 

df %>% 
  # convert dataframe into a gt object
  gt() %>%
  # add theme
  gt_theme_f5() %>%
  # add team logos
  gt_img_rows(columns = team_abbreviation, height = 30, "web") %>% 
  # hide player id columns
  cols_hide(columns = c(player1_id, player2_id)) %>% 
  # stack players on top of each other
  gt_merge_stack(col1 = player1_name, col2 = player2_name, 
                 font_size = c("14px", "14px"), 
                 font_weight = c("bold", "bold"), 
                 small_cap = F,
                 palette = c("black", "gray")) %>% 
  # add table title and subtitle
  tab_header(title = "Doubling Up", 
             subtitle = "Net Rating of commonly used double big looks") %>%
  # rename column names
  cols_label(team_abbreviation = "", 
             player1_name = "Big Combo", 
             min = "Min", 
             off_rating = md("Off.<br>Rating"), 
             def_rating = md("Def.<br>Rating"), 
             net_rating = md("Net<br>Rating")) %>% 
  # format Net Rating column
  fmt_number(net_rating, force_sign = T, decimals = 1) %>% 
  # add background color to Net Rating Column
  data_color(columns = "net_rating", 
             domain = c(-35, 35),
             alpha = .75,
             reverse = F,
             palette = "Redmonder::dPBIRdGy") %>%
  # reduce row height
  tab_options(data_row.padding = '0px') %>% 
  # save
  gt_save_crop(file = "./double_big.png", bg = 'floralwhite') 