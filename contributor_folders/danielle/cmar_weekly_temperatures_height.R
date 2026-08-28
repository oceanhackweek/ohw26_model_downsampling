library(dplyr)
library(data.table)
library(ggplot2)
library(here)
library(lubridate)
library(purrr)
library(viridis)

theme_set(theme_light())

path <- "/home/jovyan/shared-public/ohw26/model_downsampling/"

ss_get_colour_palette <- function(dat) {
  n_depth <- length(unique(dat$sensor_height_above_seafloor_m))
  
  if (n_depth > 6) {
    colour_palette <- viridis(n_depth, option = "D", direction = -1)
  } else {
    colour_palette <- viridis(6, option = "D", direction = -1)
  }
  colour_palette
}


# sea level at low tide ---------------------------------------------------
# data from Navionics (provided by CMAR field tech)
# This is the LLWLT, i.e., the average over 19 years of the lowest predicted low tide

st_depth <- fread(paste0(path, "cmar_station_depths.csv"), data.table = FALSE) %>% 
  select(station, station_depth_m) 
  
# temperature data --------------------------------------------------------

files <- list.files(path, full.names = TRUE, pattern = "cmar_temperature")

dat_raw <- map(
  files, fread, data.table = FALSE,
  colClasses = c("character", "numeric", "numeric", "numeric",
                 "POSIXct", "numeric", "numeric", "character")) %>% 
  list_rbind()

# 2 sensors end up with heights *below* the bottom of the sea floor
# this is likely from an error in measuring or recording the sensor depth
# these heights will be converted to 0 m
dat <- dat_raw %>%
  left_join(st_depth, by = "station") %>% 
  mutate(
    iso_year = isoyear(timestamp_utc),   
    iso_week = isoweek(timestamp_utc),
    year_week = paste(iso_year, "_", iso_week),
    sensor_height_above_seafloor_m = station_depth_m - sensor_depth_at_low_tide_m,
    sensor_height_above_seafloor_m = if_else(
      sensor_height_above_seafloor_m < 0, 0, sensor_height_above_seafloor_m
    )
  )

# export sensor heights ---------------------------------------------------
st_locations <- dat %>% 
  distinct(station, .keep_all = TRUE) %>% 
  select(station, latitude, longitude)

sensor_heights <- dat %>% 
  distinct(
    station, station_depth_m,
    sensor_depth_at_low_tide_m, sensor_height_above_seafloor_m
  ) %>% 
  left_join(st_locations, by = "station") %>% 
  select(station, latitude, longitude, station_depth_m, everything())

fwrite(sensor_heights, paste0(path, "cmar_sensor_heights.csv"))


# review and export weekly averages --------------------------------------------------

dat_wk <- dat %>% 
  summarise(
    mean_temperature = mean(temperature_degree_c),
    n = n(),
    .by = c(station, sensor_height_above_seafloor_m, iso_year, iso_week)
  ) 

stations <- unique(dat_wk$station)

for (i in seq_along(stations)) {
  
  station_i <- stations[i]
  
  dat_i <- dat_wk %>% 
    filter(station == station_i) 
  
  dat_i <- dat_i %>% 
    mutate(
      sensor_height_above_seafloor_m = ordered(
        sensor_height_above_seafloor_m, 
        levels = sort(unique(dat_i$sensor_height_above_seafloor_m), decreasing = TRUE)
      )
    )
  
  pal <- ss_get_colour_palette(dat_i)
  
  p <- ggplot(
    dat_i, aes(iso_week, mean_temperature, 
               colour = sensor_height_above_seafloor_m)
  ) +
    geom_point() +
    scale_colour_manual("sensor_height_m", values = pal) +
    scale_y_continuous("temperature_degree_c", limits = c(-2, 20), expand = FALSE) +
    scale_x_continuous(limits = c(0, 53), expand = FALSE) +
    facet_wrap(~iso_year, ncol = 1) +
    labs(title = station_i)
  
  print(p)
  
  n_year <- length(unique(dat_i$iso_year))

  if(n_year == 1) {
    h <- 5
  } else h <- n_year * 4.75

  ggsave(
    here(
      paste0("contributor_folders/danielle/figures/",
             gsub(" ", "_", tolower(station_i)),
             "_cmar_weekly_average_temp.png")),
    device = "png",
    width = 16, height = h, units = "cm", dpi = 600
  )
}

fwrite(dat_wk, paste0(path, "cmar_weekly_average_temperature.csv"))


