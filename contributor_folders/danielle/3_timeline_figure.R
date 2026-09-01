# this script generates a Gantt-like chart for when data is available for each station 
# (and the FVCON model)

# for an interactive version, go here: https://cmar-cmp-time-series.share.connect.posit.cloud/

library(dplyr)
library(data.table)
library(ggplot2)
library(lubridate)
library(RColorBrewer)

# read in weekly average temperature data ------------------------------------------------------------

path <- file.path("/home/jovyan/shared-public/ohw26/model_downsampling/")

dat_raw <- fread(
  paste0(path, "cmar_weekly_average_temperature.csv"), data.table = FALSE
)

# temperature data -----------------------------------------------

dat <- dat_raw %>%
  select(station, sensor_height_above_seafloor_m, iso_year, iso_week) %>% 
  # turn the iso week and years values into a proper Date object
  # modified from code suggested by Claude
  mutate(
    anchor = make_date(iso_year, 1, 4),
    week_date = anchor - days(wday(anchor, week_start = 1) - 1) + weeks(iso_week - 1)
  ) %>% 
  select(-anchor) %>% 
  group_by(station, sensor_height_above_seafloor_m) %>%
  # preliminary values - these get updated below if needed:
  mutate(
    depl_start = as_date(min(week_date)),
    depl_end = as_date(max(week_date))
  ) %>%
  ungroup() 

# find when the gaps in each time series start ---------------------------------------------------------------

# all time series - bind with results below so that ts without gaps are not dropped
out_table <- dat %>% 
  distinct(station, sensor_height_above_seafloor_m, depl_start, depl_end)

# start data of data gaps
dat_gap <- dat %>%
  group_by(station, sensor_height_above_seafloor_m, depl_start, depl_end) %>%
  # MUST be in chronological order
  arrange(week_date, .by_group = TRUE) %>%
  # difference between next observation and this observation in weeks
  mutate(
    gap_length_weeks = as.numeric(difftime(lead(week_date), week_date, units = "weeks")
  )) %>%
  filter(gap_length_weeks > 1) %>%
  mutate(gap_start = week_date) %>% 
  ungroup() %>%
  right_join(out_table) %>%
  mutate(
    gap_length_weeks = if_else(is.na(gap_length_weeks), 0, gap_length_weeks),
    gap_length_days = gap_length_weeks * 7
  )

# continuous time series --------------------------------------------------

# to fill in the end date after the last gap
dat_end <- dat %>%
  distinct(station, sensor_height_above_seafloor_m, depl_end) %>%
  rename(end_date = depl_end)

# start and end of each continuous time series
dat_out <- dat_gap %>%
  rename(end_date = gap_start) %>%  # date data ends; start of gap
  bind_rows(dat_end) %>%
  group_by(station, sensor_height_above_seafloor_m) %>%
  mutate(
    row_id = 1:n(),
    start_date = if_else(
      row_id == 1, depl_start, lag(end_date) + lag(days(round(gap_length_days)))
    ),
    end_date = if_else(
      is.na(end_date) & row_id == 1 & gap_length_days == 0, depl_end, end_date
    )
  ) %>%
  ungroup() %>%
  filter(!is.na(start_date)) %>%  # duplication rows for stations without any gaps
  mutate(
    ts_length_weeks = difftime(end_date, start_date, units = "weeks"),
    ts_length_weeks = round(as.numeric(ts_length_weeks), digits = 2)
  ) %>%
  arrange(station, sensor_height_above_seafloor_m, start_date) %>%
  select(
   station, sensor_height_above_seafloor_m, start_date, end_date, ts_length_weeks
  ) %>% 
  bind_rows(
    data.frame(
    station = "FVCOM Model",
    start_date = as_date("2016-12-31"),
    end_date = as_date("2018-01-05"))
  )

# generate figure --------------------------------------------------------

theme_set(theme_light()) # use light background for figures

pal_foo <- colorRampPalette(brewer.pal(8, "Dark2"))
pal <- pal_foo(length(unique(dat_out$station)))

ggplot(dat_out) +
  geom_segment(
    aes(
      x = start_date, xend = end_date, 
      y = station, yend = station, col = station
    ), linewidth = 4
  ) +
  scale_y_discrete(limits = rev) +
  scale_colour_manual(values = pal, drop = FALSE) +
  theme(
    legend.position = "none",
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.border = element_rect(colour = "gray20"),
    strip.background = element_rect(colour = "gray20", fill = "gray40"),
    panel.spacing.x = unit(-1, "lines")
  )

ggsave(
  here(
    paste0("contributor_folders/danielle/figures/data_timeline.png")),
  device = "png",
  width = 16, height = 8, units = "cm", dpi = 600
)


# by station + height
# dat_out %>% 
#   filter(station != "FVCOM Model") %>% 
#   ggplot() +
#   geom_segment(
#     aes(
#       x = start_date, xend = end_date, 
#       y = sensor_height_above_seafloor_m, 
#       yend = sensor_height_above_seafloor_m, 
#       col = station
#     ), linewidth = 1
#   ) +
#   scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
#   scale_colour_manual(values = pal, drop = FALSE) +
#   facet_wrap(~station, ncol = 2) +
#   theme(
#     legend.position = "none",
#     axis.title.x = element_blank(),
#     panel.border = element_rect(colour = "gray20"),
#     panel.grid.minor = element_blank(),
#     strip.background = element_rect(colour = "gray20", fill = "gray40")
#   )
# 
# ggsave(
#   here(
#     paste0("contributor_folders/danielle/figures/data_timeline_height.png")),
#   device = "png",
#   width = 16, height = 18, units = "cm", dpi = 600
# )
