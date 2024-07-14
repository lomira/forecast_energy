library(tidyverse)
library(janitor)
library(openmeteo)

source("src/import.R")
aep_hourly <- read_csv("data/raw/AEP_hourly.csv") |> clean_names()

aep_daily <- aep_hourly |> 
  aggregate_time_series(
    datetime_col = datetime,
    value_col = aep_mw, 
    fn_reduction = max, 
    time_unit = "day",
    output_col = "daily_peak_MW"
  )

# Weather
weather_colombus <- weather_history(
  location = c(29.7066,-96.5397),
  start = min(aep_daily$date),
  end = max(aep_daily$date),
  hourly = c(
    "temperature_2m",
    "relative_humidity_2m",
    "apparent_temperature",
    "precipitation",
    "cloud_cover",
    "wind_speed_10m"
  )
)

weather_colombus_day <- weather_colombus |> 
mutate(date = lubridate::floor_date(datetime, "day")) |> 
summarise(
  .by = date,
  across(
    contains(c("temperature", "wind_speed_10m")),
    list(mean = mean, min = min, max = max),
    .names = "{.col}.{.fn}"
  ),
  across(
    contains(c("relative_humidity_2m", "cloud_cover")),
    list(mean = mean),
    .names = "{.col}.{.fn}"
  ),
  across(
    contains(c("precipitation")),
    list(mean = mean),
    .names = "{.col}.{.fn}"
  )
)

XY <- left_join(aep_daily, weather_colombus_day, by = join_by(date==date))
write_rds(weather_colombus, "data/processed/weather_colombus.rds")
write_rds(weather_colombus_day, "data/processed/weather_colombus_day.rds")
write_rds(XY, "data/processed/XY.rds")
