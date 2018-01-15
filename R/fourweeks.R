#' Lookup table of four-week periods
#'
#' A lookup table of the four-week periods used in the dataset `underground`
#'
#' This dataset may be updated approximately monthly.  To use the latest data,
#' reinstall the package from the GitHub repository
#' https://github.com/nacnudus/underground.
#'
#' Some series of the London Underground Services performance data are reported
#' in periods approximately four weeks long.  Some periods are shorter or longer
#' by a day or more, so that each year is covered by 13 periods, beginning on
#' the 1st of April.
#'
#' @format A data frame with 86 rows and 5 variables:
#'
#' * `year`     The year (from 1 April to 31 May, e.g. "2011/12")
#' * `fourweek` The number of the four-week period within the year (1 to 13)
#' * `start`    The date of the first day of the four-week period
#' * `start`    The date of the last day of the four-week period
#' * `days`     The length of the four-week period in days.  Usually it is 28
#'                days long, but is sometimes shorter or longer so that each
#'                year is covered by 13 periods.
#'
#' @source
#' https://data.london.gov.uk/dataset/london-underground-performance-reports,
#' the file "tfl-tube-performance.xls"
"fourweeks"

