# this script generates a time series figure showing all data from the 
# Long Island 2 station
# these are the raw values (NOT weekly averages)

library(dplyr)
library(data.table)
library(ggplot2)
library(here)
library(lubridate)
library(purrr)
library(viridis)

# read in data ------------------------------------------------------------

path <- "/home/jovyan/shared-public/ohw26/model_downsampling/"

dat <- fread(paste0(path, "cmar_temperature.csv")) %>% 
  filter(station == "Long Island 2") 

dat <- dat %>% 
  mutate(
    sensor_depth_at_low_tide_m = ordered(
      sensor_depth_at_low_tide_m, 
      levels = sort(unique(dat$sensor_depth_at_low_tide_m))
    ))

# plot --------------------------------------------------------------------

theme_set(theme_light())

pal_foo <- colorRampPalette(viridis(6, direction = -1))
pal <- pal_foo(length(unique(dat$sensor_depth_at_low_tide_m)))

p <- ggplot(dat, aes(timestamp_utc, temperature_degree_c, col = sensor_depth_at_low_tide_m)) +
  geom_point(size = 0.25) +
  scale_colour_manual("Sensor Depth (m)", values = pal) +
  scale_y_continuous("Temperature (degree C)") +
  theme(legend.position = "bottom", axis.title.x = element_blank()) +
  guides(
    color = guide_legend(nrow = 1, override.aes = list(size = 4))
  )

ggsave(
  here(
    paste0("contributor_folders/danielle/figures/cmar_temperature_ts.png")),
  device = "png",
  width = 24, height = 10, units = "cm", dpi = 600
)




