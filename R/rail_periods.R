#' Lookup table of four-week periods
#'
#' A lookup table of the four-week-ish 'Control Periods' used by the UK rail
#  industry.
#'
#' Some series of the London Underground Services performance data are reported
#' in 'periods' approximately four weeks long.  Some periods are shorter or
#' longer so that each year is covered by exactly 13 periods, beginning on the
#' April the 1st.
#'
#' @format A data frame with 533 rows and 5 variables:
#'
#' * `year`     The financial year (from 1 April to 31 May, e.g. "2011/12")
#' * `period`   The number of the four-week period within the year (1 to 13)
#' * `start`    The date of the first day of the period
#' * `start`    The date of the last day of the period
#' * `days`     The length of the four-week period in days.  Usually it is 28
#'                days long, but some periods are shorter or longer so that each
#'                year is covered by exactly 13 periods.
#'
#' @source
#' The data was obtained by private corresponce with the [Office for Road and
#' Rail](http://orr.gov.uk).  It is similar to data published
#' [online](http://dataportal.orr.gov.uk/browsereports/19),
#' but over a much wider range of years.  Similar data published by others
#' differs slightly.  This package author regards the Office for Road and Rail
#' as the authoritative source.
"rail_periods"
