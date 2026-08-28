library(dplyr)
library(data.table)
library(ggplot2)
library(lubridate)
library(RColorBrewer)

theme_set(theme_light())

path <- file.path("/home/jovyan/shared-public/ohw26/model_downsampling/")

dat_raw <- fread(
  paste0(path, "cmar_weekly_average_temperature.csv"), data.table = FALSE
)

sum(is.na(dat_raw$mean_temperature))

# temperature data -----------------------------------------------

dat <- dat_raw %>%
  select(station, sensor_height_above_seafloor_m, iso_year, iso_week) %>% 
  mutate(
    anchor = make_date(iso_year, 1, 4),
    week_date = anchor - days(wday(anchor, week_start = 1) - 1) + weeks(iso_week - 1)
  ) %>% 
  group_by(station, sensor_height_above_seafloor_m) %>%
  mutate(
    depl_start = as_date(min(week_date)),
    depl_end = as_date(max(week_date))
  ) %>%
  ungroup() %>% 
  select(-anchor)

# data gaps ---------------------------------------------------------------

# gaps in time series
out_table <- dat %>% 
  distinct(station, sensor_height_above_seafloor_m, depl_start, depl_end)

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
    start_date = as_date("2016-01-01"),
    end_date = as_date("2016-12-31"))
  )


# generate figures --------------------------------------------------------

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

