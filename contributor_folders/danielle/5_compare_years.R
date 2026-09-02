library(dplyr)
library(data.table)
library(ggplot2)
library(here)
library(lubridate)
library(viridis)

path <- "/home/jovyan/shared-public/ohw26/model_downsampling/"

dat_raw <- fread(
  paste0(path, "cmar_weekly_average_temperature.csv"), data.table = FALSE
)

dat_raw %>% 
  summarise(n_year = length(unique(iso_year)), .by = station) %>% 
  arrange(desc(n_year))
