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
#' @format A data frame with 568 rows and 5 variables:
#'
#' * `year`     The financial year (from 1 April to 31 May, e.g. "2011/2012")
#' * `period`   The number of the four-week period within the year (1 to 13)
#' * `start`    The date of the first day of the period
#' * `start`    The date of the last day of the period
#' * `days`     The length of the four-week period in days.  Usually it is 28
#'                days long, but some periods are shorter or longer so that each
#'                year is covered by exactly 13 periods.
#'
#' @source
#' The source is not disclosed.  It is similar to a
#' [document](https://www.whatdotheyknow.com/request/historic_knowledge_of_london_sta)
#' obtained via the Freedom of Information Act, except the boundary between
#' periods 12 and 13 in the year 2009/10.  Another
#' [source](http://dataportal.orr.gov.uk/displayreport/report/html/d986b6bf-5ca7-45c4-800c-75156d93e1a8)
#' by the Office for Rail and Road was used to confirm that boundary.  Other
#' sources have been seen but not used, for example
#' https://data.london.gov.uk/dataset/london-underground-performance-reports,
#' the file "tfl-tube-performance.xls".  Enquiries for definitive information
#' are being made through official channels.
"rail_periods"
