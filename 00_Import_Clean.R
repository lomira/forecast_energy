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
    time_unit = "month")

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

write_rds(weather_colombus, "data/processed/weather_colombus.rds")
