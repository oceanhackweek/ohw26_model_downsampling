# This script does this following: 1. Reads in the observed cmar temperature
# data ("cmar_temperature.csv"). 2. Converts
# "sensor_depth_below_surface_at_low_tide_m" to
# "sensor_height_above_seafloor_m". 3. Calculates the mean and standard
# deviation of weekly temperatures using two different aggregations. 4. Exports
# the files "cmar_average_temperature_year_week.csv" and
# "cmar_average_temperature_week.csv"

# cmar_average_temperature_year_week.csv: temperatures are averaged by
# year, iso week, station, and height. Use this to assess how different the
# weekly averages are between years, i.e, how much variability is in a
# "representative year"

# cmar_average_temperature_week.csv: temperatures are averaged by
# iso week, station, and height. 


library(dplyr)
library(data.table)
library(ggplot2)
library(here)
library(lubridate)
library(purrr)
library(viridis)

source(here("contributor_folders/danielle/functions/helpers.R"))

path <- "/home/jovyan/shared-public/ohw26/model_downsampling/"


# sea level at low tide for each CMAR station ---------------------------------------------------

# This data from Navionics charts (provided by CMAR field tech).
# This is the LLWLT (Lower Low Water Large Tide), i.e., the average over 
# 19 years of the lowest predicted low tide

# We used this source because our recorded sensor *depth* is measured relative
# to low tide. The actual sensor depth below the surface changes with the tide.
# We want to calculate the sensor height above the sea floor, because the height
# does not change over time. 

# The observed temperatures at these heights will be compared to the FVCON
# modeled temperatures from the nearest model layer height.

# Note: the latitude and longitudes recorded in this file are the "official"
# station coordinates. All stations with this name must be within 500 m of these
# coordinates. The lat/longs in "cmar_temperature.csv" are more precise because
# they were recorded for each specific  deployment. For now we will use the
# official station coordinates to simplify the data format (otherwise we need
# multiple station locations for a single station)

st_depth <- fread(paste0(path, "cmar_station_depths.csv"), data.table = FALSE) %>% 
  rename(station_elevation_m = station_depth_m)

# import data & convert sensor depth to height --------------------------------------------------------

# raw temperature data from CMAR's Coastal Monitoring Program for Digby County 
dat_raw <- fread(paste0(path, "cmar_temperature.csv"), data.table = FALSE)

# Two sensors end up with heights *below* the bottom of the sea floor.
# This is likely from an error in measuring or recording the sensor depth.
# These negative heights are converted to 0 m
dat <- dat_raw %>%
  # replace the deployment specific coordinates with the official station coordinates
  select(-latitude, -longitude) %>%  
  left_join(st_depth, by = "station") %>% 
  mutate(
    iso_year = lubridate::isoyear(timestamp_utc),   
    iso_week = lubridate::isoweek(timestamp_utc),
    sensor_height_above_seafloor_m = station_elevation_m - sensor_depth_at_low_tide_m,
    sensor_height_above_seafloor_m = if_else(
      sensor_height_above_seafloor_m < 0, 0, sensor_height_above_seafloor_m
    )
  )

#  average temperature by year, week, station, and height -----------------
dat_year_week <- dat %>% 
  summarise(
    mean_temperature_degree_c = round(mean(temperature_degree_c), digits = 3),
    sd_temperature_degree_c = round(sd(temperature_degree_c), digits = 3),
    n = n(),
    .by = c(
      station, station_elevation_m, sensor_height_above_seafloor_m, 
      latitude, longitude, iso_year, iso_week)
  ) %>%
  select(
    station, station_elevation_m, latitude, longitude,
    iso_year, iso_week, n, sensor_height_above_seafloor_m,
    mean_temperature_degree_c, sd_temperature_degree_c
  ) %>%
  arrange(station, iso_year, iso_week)

fwrite(dat_year_week, paste0(path, "cmar_average_temperature_year_week.csv"))


#  average temperature by week, station, and height -----------------
dat_week <- dat %>% 
  summarise(
    mean_temperature_degree_c = round(mean(temperature_degree_c), digits = 3),
    sd_temperature_degree_c = round(sd(temperature_degree_c), digits = 3),
    n = n(),
    .by = c(
      station, station_elevation_m, sensor_height_above_seafloor_m, 
      latitude, longitude, iso_week)
  ) %>%
  select(
    station, station_elevation_m, latitude, longitude, iso_week,
    n, sensor_height_above_seafloor_m,
    mean_temperature_degree_c, sd_temperature_degree_c
  ) %>%
  arrange(station, iso_week)

fwrite(dat_week, paste0(path, "cmar_average_temperature_week.csv"))


# if a specific sensor height file is still needed:
sensor_heights <- dat %>%
  distinct(
    station, latitude, longitude, station_elevation_m,
    sensor_depth_at_low_tide_m, sensor_height_above_seafloor_m
  )
fwrite(sensor_heights, paste0(path, "cmar_sensor_heights.csv"))

# plot weekly averages ----------------------------------------------------
# moved to quarto docs

# theme_set(theme_light())
# 
# stations <- unique(dat$station)
# 
# for (i in seq_along(stations)) {
#   
#   station_i <- stations[i]
#   
#   dat_i <- dat %>% 
#     filter(station == station_i) %>% 
#     # this is so a discrete colour scale is used for sensor height
#     mutate(
#       sensor_height_above_seafloor_m = 
#         convert_to_ordered_factor(sensor_height_above_seafloor_m)
#     )
#     
#   pal <- viridis(
#     length(unique(dat_i$sensor_height_above_seafloor_m)), option = "D", direction = -1
#   )
#   
#   p <- ggplot(
#     dat_i, aes(iso_week, mean_temperature_degree_c, colour = sensor_height_above_seafloor_m)
#   ) +
#     geom_point() +
#     scale_colour_manual("sensor_height_m", values = pal) +
#     scale_y_continuous("temperature_degree_c", limits = c(-2, 20), expand = FALSE) +
#     scale_x_continuous(limits = c(0, 53), expand = FALSE) +
#     facet_wrap(~iso_year, ncol = 1) +
#     labs(title = station_i)
#   
#   print(p)
#   
#   # n_year <- length(unique(dat_i$iso_year))
#   # 
#   # if(n_year == 1) {
#   #   h <- 5
#   # } else h <- n_year * 4.75
#   # 
#   # ggsave(
#   #   here(
#   #     paste0("contributor_folders/danielle/figures/",
#   #            gsub(" ", "_", tolower(station_i)),
#   #            "_cmar_weekly_average_temp.png")),
#   #   device = "png",
#   #   width = 16, height = h, units = "cm", dpi = 600
#   # )
# }

