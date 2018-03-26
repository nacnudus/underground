#' London Underground Services Performance Data
#'
#' A dataset of the London Underground services performance data timeseries from
#' 2003/04 to 3 March 2018.
#'
#' This dataset may be updated approximately monthly.  To use the latest data,
#' reinstall the package from the GitHub repository
#' https://github.com/nacnudus/underground.
#'
#' There are many series, each given annually as well as one of quarterly and
#' four-weekly.  Most series are broken down by line, others are broken down by
#' other things as follows.
#'
#' * Various Lost Customer Hours series are broken down by `line`, `category`
#'   (which is really 'cause'), and `company` (see 'Details')
#' * Escalator and Lift Mean Time Between Failures (Days) is broken down by
#'   `asset` (lift or escalator)
#'
#' @format A data frame with 103,082 rows and 8 variables:
#'
#' * `metric`   The title of the data series
#' * `year`     Year beginning 1 April
#' * `quarter`  The quarter, e.g. `"QTR 1"` of year beginning 1 April, for
#'              quarterly series
#' * `fourweek` The four-week period within the year beginning 1 April, for
#'              four-weekly series. I don't know whether the 13th and final
#'              period is a day longer.
#' * `line`     The London Underground Line, for series broken down by line
#' * `category` The cause of loss of customer hours, for some Lost Customer
#'              Hours series
#' * `asset`    Either `Escalators - MTBF (days)` or `Lifts - MTBF (days)`, for
#'              the series "Escalator and Lift Mean Time Between Failures
#'              (Days)"
#' * `company`  The company concerned, for some Lost Customer Hours series (see
#'              'Details')
#' * `value`    The observed value of the metric
#'
#' @details
#'
#' What the `company` column means:
#'
#' `BCV` = Bakerloo, Central, Victoria (and Waterlool & City)
#' `SSL` = Sub-Surface Lines (District, Hammersmith and City, Metropolitan,
#'         Circle and East London)
#' `JNP` = Jubilee, Northern, Picadilly
#'
#' From https://en.wikipedia.org/wiki/Talk%3ATransport_for_London:
#'
#' "The maintenance and upgrading of the London Underground Network is carried
#' out by different companies. Tube Lines in responsible for the Jubilee,
#' Northern and Piccadilly Lines (JNP), Metronet BCV is responsible for the
#' Bakerloo, Central and Victoria Lines (BCV) as well as the Waterloo and City
#' Line, whilst Metronet SSL (sub surface lines) is responsible for the District,
#' Hammersmith and City, Metropolitan, Circle and East London lines." DavidB601
#' 20:57, 7 November 2006 (UTC)
#'
#' @source
#' https://tfl.gov.uk/corporate/publications-and-reports/underground-services-performance
"underground"
