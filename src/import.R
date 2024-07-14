#' Reduce the time of Time Series Data stored in tibble
#'
#' This function takes a data frame or tibble with time series observations and
#' aggregates it to a specified time unit using a given reduction function.
#'
#' @param .data A data frame or tibble containing the time series data.
#' @param datetime_col The name of the column containing datetime information.
#' @param value_col The name of the column containing the values to be aggregated.
#' @param fn_reduction A function to be applied for data reduction (e.g., max, mean, sum).
#' @param time_unit The time unit to aggregate to. One of "day", "month", or "year".
#' @param output_col The name of the output column for the aggregated value. Defaults to "aggregated_value".
#'
#' @return A tibble with aggregated data, containing a 'date' column and the specified output column.
#'
#' @examples
#' library(dplyr)
#' library(lubridate)
#'
#' # Sample data
#' hourly_data <- tibble(
#'   timestamp = seq(ymd_h("2023-01-01 00"), by = "hour", length.out = 1000),
#'   value = runif(1000, 0, 100)
#' )
#'
#' # Aggregate to daily maximum
#' daily_max <- aggregate_time_series(hourly_data, timestamp, value, max, "day", "daily_max")
#'
#' # Aggregate to monthly mean
#' monthly_mean <- aggregate_time_series(hourly_data, timestamp, value, mean, "month", "monthly_avg")
#'
#' # Aggregate to yearly sum
#' yearly_sum <- aggregate_time_series(hourly_data, timestamp, value, sum, "year", "yearly_total")
#'
#' @export
aggregate_time_series <- function(
  .data, 
  datetime_col, 
  value_col, 
  fn_reduction, 
  time_unit = "day", 
  output_col = "aggregated_value") {
  
  # Input validation
  if (!is.data.frame(.data)) {
    stop(".data must be a data frame or tibble")
  }
  if (nrow(.data)<1) {
    stop(".data must have data")
  }
  if (!time_unit %in% c("day", "month", "year")) {
    stop("time_unit must be one of 'day', 'month', or 'year'")
  }
  if (!is.character(output_col) || length(output_col) != 1) {
    stop("output_col must be a single character string")
  }
  
  datetime_col <- rlang::ensym(datetime_col)
  value_col <- rlang::ensym(value_col)
  
  if (!rlang::as_string(datetime_col) %in% names(.data)) {
    stop("datetime_col must be a column in .data")
  }
  if (!rlang::as_string(value_col) %in% names(.data)) {
    stop("value_col must be a column in .data")
  }
  
  # Define the date function based on the time_unit
  date_fn <- switch(
    time_unit,
    "day" = function(x) lubridate::floor_date(x, "day"),
    "month" = function(x) lubridate::floor_date(x, "month"),
    "year" = function(x) lubridate::floor_date(x, "year")
  )
  
  tryCatch(
    {
      with_date <- .data |> 
        dplyr::mutate(date = date_fn(!!datetime_col))
    }, error = function(e) {
      stop(
        paste(
          "Error in convert:", e$message, 
          "\nPlease ensure that 'datetime_col' contains valid date-time data."
        )
      )
    }
  )
  
  tryCatch({
    out <- with_date |> 
      dplyr::summarise(
        .by = date, 
        !!output_col := fn_reduction(!!value_col)
      )
  }, error = function(e) {
    stop(paste("Error in aggregation:", e$message))
  })
  
  return(out)
}
