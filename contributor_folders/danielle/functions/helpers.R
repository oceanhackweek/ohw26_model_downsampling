# Convert numeric values to an ordered factor. Typically used to convert
# sensor_height_from_seafloor_m to ordered factor so a discrete colour scale is
# used when plotting temperature over time, coloured by sensor height. Also so
# that legend is ordered from shallowest to deepest sensors .
# The function is used to keep a continuous pipe.

# v_numeric: numeric vector. Can be a column in a data frame.

# TODO: add warning or error if there are too many f_levels

convert_to_ordered_factor <- function(v_numeric) {
  
  f_levels <- sort(unique(v_numeric), decreasing = TRUE)
  ordered(v_numeric, levels = f_levels)
}

# quick check (doesn't run when file is sourced)
if (FALSE) {
  
  v <- c(10, 4.2, 4.2, 4.2, 12, 12, 12, 12, 54, 54, 54)
  v_f <- convert_to_ordered_factor(v)
  unique(v_f)
  
  
  df <- data.frame(
    sensor_height_above_seafloor_m = c(9, 1, 1, 1, 5, 5)
  ) %>%
    mutate(
      sensor_height_f = convert_to_ordered_factor(sensor_height_above_seafloor_m)
    )
  
  unique(df$sensor_height_f)
}

# Turn the iso year and iso week into a date object. The day will be the Monday
# of the week specified by iso_year and iso_week

# From wikipedia:
# The ISO 8601 definition for week 01 is the week with the first Thursday of
# the Gregorian year (i.e., of January) in it.
# It is the first week with a majority (4 or more) of its days in January.

# code modified from Claude suggestions
make_date_from_iso_year_week <- function(iso_year, iso_week) {
  
  anchor = lubridate::make_date(iso_year, 1, 4)
  
  anchor - days(wday(anchor, week_start = 1) - 1) + weeks(iso_week - 1)
}

# check compared to examples online 
# https://www.generalblue.com/week-number-calculator
if (FALSE) {
  
  # 2016-01-04
  make_date_from_iso_year_week(iso_year = 2016, iso_week = 1)
  
  # 2026-12-26
  make_date_from_iso_year_week(iso_year = 2016, iso_week = 52)
  
  # this should probably give an error/warning, since it is more correct to use
  # 2017-W01
  make_date_from_iso_year_week(iso_year = 2016, iso_week = 53)
  
  # 2017-01-02
  make_date_from_iso_year_week(iso_year = 2017, iso_week = 1)
  
  # 2020-06-22
  make_date_from_iso_year_week(2020, 26)
  
  # 2022-11-07
  make_date_from_iso_year_week(2022, 45)
  
}




# Assign different sizes to figures generated from a loop in RMarkdown
# Modified from http://michaeljw.com/blog/post/subchunkify/
# g: the plot object

subchunkify <- function(g, fig_height = 7, fig_width = 5, fig_i = NULL) {
  
  if(is.null(fig_i)) {fig_i <- floor(runif(1) * 10000)}
  
  
  g_deparsed <- paste0(deparse(
    function() {g}
  ), collapse = '')
  
  sub_chunk <- paste0("```{r sub_chunk_", fig_i, ", fig.height=", fig_height, ", fig.width=", fig_width, "}",
                      "\n(",
                      g_deparsed
                      , ")()",
                      "\n`","``")
  
  cat(knitr::knit(text = knitr::knit_expand(text = sub_chunk), quiet = TRUE))
}


