# function for saving shotdetail
load_nba_data <- function(path = getwd(),
                          seasons = seq(1996, 2023),
                          data = c("datanba", "nbastats", "pbpstats", "shotdetail", "cdnnba", "nbastatsv3"),
                          seasontype = 'rg',
                          untar = FALSE){
  
  if(seasontype == 'rg'){
    df <- expand.grid(data, seasons)
    need_data <- paste(df$Var1, df$Var2, sep = "_")
  } else if(seasontype == 'po'){
    df <- expand.grid(data, 'po', seasons)
    need_data <- paste(df$Var1, df$Var2, df$Var3, sep = "_")
  } else {
    df_rg <- expand.grid(data, seasons)
    df_po <- expand.grid(data, 'po', seasons)
    need_data <- c(paste(df_rg$Var1, df_rg$Var2, sep = "_"), paste(df_po$Var1, df_po$Var2, df_po$Var3, sep = "_"))
  }
  temp <- tempfile()
  download.file("https://raw.githubusercontent.com/shufinskiy/nba_data/main/list_data.txt", temp)
  f <- readLines(temp)
  unlink(temp)
  
  v <- unlist(strsplit(f, "="))
  
  name_v <- v[seq(1, length(v), 2)]
  element_v <- v[seq(2, length(v), 2)]
  
  need_name <- name_v[which(name_v %in% need_data)]
  need_element <- element_v[which(name_v %in% need_data)]
  
  if(!dir.exists(path)){
    dir.create(path)
  }
  
  for(i in seq_along(need_element)){
    destfile <- paste0(path, '/', need_name[i], ".tar.xz")
    download.file(need_element[i], destfile = destfile)
    if(untar){
      untar(destfile, paste0(need_name[i], ".csv"), exdir = path)
      unlink(destfile)
    }
  }
}

# get shot data for 2024 and save it in a folder called data/shotdetail/
load_nba_data(path = "data/shotdetail/", 
              seasons = 2024,  
              data = "shotdetail", 
              untar = TRUE)

# Load packages 
library(tidyverse)
library(devtools)
library(duckdb)
library(DBI)
library(metR)
library(ggtext)
library(extrafont)
library(ggnewscale)

# Custom ggplot2 theme
theme_f5 <- function (font_size = 9) { 
  theme_minimal(base_size = font_size, base_family = "Roboto") %+replace% 
    theme(
      plot.background = element_rect(fill = 'floralwhite', color = "floralwhite"), 
      panel.grid.minor = element_blank(), 
      plot.title = element_text(hjust = 0, size = 14, face = 'bold'), 
      plot.subtitle = element_text(color = 'gray65', hjust = 0, margin=margin(2.5,0,10,0), size = 11), 
      plot.caption = element_text(color = 'gray65', margin=margin(-5,0,0,0), hjust = 1, size = 6)
    )
}

# Load NBA court dimensions from github
source_url("https://github.com/Henryjean/NBA-Court/blob/main/CourtDimensions.R?raw=TRUE")

# Set DuckDB connection
con <- dbConnect(duckdb())

# Read in relevant data
df <- dbGetQuery(
  con,
  paste0("select PLAYER_NAME, LOC_X, LOC_Y, SHOT_DISTANCE from read_csv('data/shotdetail/shotdetail_2024.csv') where SHOT_DISTANCE <= 35")
) 

# Reformat x,y location data
df <- df %>% mutate(locationX = LOC_X / 10 * -1,
                    locationY = LOC_Y / 10 + hoop_center_y) 

# Set up our function for manually calculating the density of an area 
get_density <- function(x, y, ...) {
  density_out <- MASS::kde2d(x, y, ...)
  int_x <- findInterval(x, density_out$x)
  int_y <- findInterval(y, density_out$y)
  comb_int <- cbind(int_x, int_y)
  return(density_out$z[comb_int])
}

# set player of interest
player_of_interest = "Isaiah Hartenstein"
# how detailed we want our contours to be (don't recommend going much above 300)
n = 300

# filter data to our player of interest, assign it to p1
p1 <- df %>% 
  select(locationX, locationY, PLAYER_NAME) %>% 
  filter(PLAYER_NAME == player_of_interest) 

# filter data for every player other than our player of interest, assign it to p2
p2 <- df %>% 
  select(locationX, locationY, PLAYER_NAME) %>% 
  filter(PLAYER_NAME != player_of_interest)

# get x/y coords as vectors
p1_x <- pull(p1, locationX)
p1_y <- pull(p1, locationY)

# get x/y coords as vectors
p2_x <- pull(p2, locationX)
p2_y <- pull(p2, locationY)

# get x and y range to compute comparisons across
x_rng = range(c(-27.5, 27.5))
y_rng = range(c(0, 52))

# Explicitly calculate bandwidth for future use
bandwidth_x <- MASS::bandwidth.nrd(c(p1_x, p2_x))
bandwidth_y <- MASS::bandwidth.nrd(c(p1_y, p2_y))

bandwidth_calc <- c(bandwidth_x, bandwidth_y)

# Calculate the density estimate over the specified x and y range
d2_p1 = MASS::kde2d(p1_x, p1_y, h = c(7, 7), n=n, lims=c(x_rng, y_rng))
d2_p2 = MASS::kde2d(p2_x, p2_y, h = c(7, 7), n=n, lims=c(x_rng, y_rng))

# Create a new dataframe that contains the difference in shot density between our two dataframes 
df_diff <- d2_p1

# matrix subtraction density from p1 from league average
df_diff$z <- d2_p1$z - d2_p2$z

# add matrix col names
colnames(df_diff$z) <- df_diff$y

# Convert list to dataframe with relevant variables and columns
df_diff <- df_diff$z %>% 
  as_tibble() %>% 
  mutate(x_coord = df_diff$x) %>% 
  pivot_longer(-x_coord, names_to = "y_coord", values_to = "z") %>% 
  mutate(y_coord = as.double(y_coord))

# create a separate dataframe for values that are less than 0
df_negative <- df_diff %>% filter(z < 0)
# make positive 
df_negative$z <- abs(df_negative$z)

# if less than 0, make 0
df_diff$z <- ifelse(df_diff$z < 0, 0, df_diff$z)

ggplot()  +
  # plot court
  geom_path(data = court_points,
            aes(x = x, y = y, group = desc, linetype = dash),
            color = "black", linewidth = .25)  +
  coord_fixed(clip = 'off') +
  # custom theme
  theme_f5()  +
  # set opacity limits
  scale_alpha_continuous(range = c(0.4, 1)) +
  # set y-axis limits
  scale_y_continuous(limits = c(-2.5, 45)) +
  # set x-axis limits
  scale_x_continuous(limits = c(-30, 30)) + 
  # first layer
  geom_raster(data = df_diff %>% filter(z >= mean(z)), aes(x = x_coord, y = y_coord, alpha = sqrt(z), fill = sqrt(z)))  +
  stat_contour(data = df_diff %>% filter(z >= mean(z)), aes(x = x_coord, y = y_coord, z = sqrt(z), color = ..level..), linewidth = .25, bins = 4) +
  scale_fill_gradient2(low = 'floralwhite', mid = 'floralwhite', high = "#cc0000",  trans = 'sqrt')  +
  scale_color_gradient2(low = "floralwhite", mid = 'floralwhite', high = "#cc0000",  trans = 'sqrt') +
  # second layer
  new_scale_fill() +
  new_scale_color() +
  geom_raster(data = df_negative %>% filter(z >= mean(z)), aes(x = x_coord, y = y_coord, alpha = sqrt(z), fill = sqrt(z)))  +
  stat_contour(data = df_negative %>% filter(z >= mean(z)), aes(x = x_coord, y = y_coord, z = sqrt(z), color = ..level..), linewidth = .25, bins = 4) +
  scale_fill_gradient2(low = "floralwhite", mid = "floralwhite", high = "#aaaaaa",  trans = 'sqrt') +
  scale_color_gradient2(low = "floralwhite", mid = "floralwhite", high = "#aaaaaa", trans = 'sqrt') +
  # theme tweaks
  theme(legend.position = 'none',
        line = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(), 
        plot.margin = margin(.25, 0, 0.25, 0, "lines"),
        plot.title = element_text(face = 'bold', hjust= .5, vjust = -2.5, family = "Roboto"))  +
  labs(title = player_of_interest)

ggsave("IsaiahHartenstein.png", w = 6, h = 2, dpi = 600)