#' London Underground Palette
#'
#' A palette for the London Underground lines, based on the official palette.
#'
#' The same yellow as for the Circle Line is used for the combination of the
#' Circle and Hammersmith & City lines.
#'
#' For 'All Lines', the pink colour of the Transport for London Visitor Centre
#' is used.
#'
#' `underground_lines` is the complement of `underground_colours` (swapping the
#' names and values), for using as the `labels` argument to
#' ggplot2::scalel_*_identity().
#'
#' @export
#' @examples
#' underground_colours
#' underground_colors
#' underground_lines
#'
#' \dontrun{
#'   underground %>%
#'     filter(metric == "Train delays longer than 15 minutes",
#'            year == "2016/17",
#'            is.na(fourweek),
#'            is.na(quarter),
#'            line != "All Lines") %>%
#'     mutate(fill= underground_colours[line]) %>%
#'     select(line, value, fill) %>%
#'     ggplot(aes(line, value, fill = fill)) +
#'     geom_bar(stat = "identity") +
#'     scale_fill_identity("", labels = underground_lines, guide = "legend") +
#'     theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
#'     xlab("") +
#'     ylab("") +
#'     ggtitle("Train delays longer than 15 minutes (2016/17)")
#' }
underground_colours <-
  c(`All Lines`          = rgb(220,   0, 107, maxColorValue = 255),
    `Bakerloo`           = rgb(178,  99,   0, maxColorValue = 255),
    `Central`            = rgb(220,  36,  31, maxColorValue = 255),
    `Circle`             = rgb(255, 211,  41, maxColorValue = 255),
    `Circle + H&C`       = rgb(255, 211,  42, maxColorValue = 255), # one-off to be distinct
    `District`           = rgb(  0, 125,  50, maxColorValue = 255),
    `Hammersmith & City` = rgb(244, 169, 190, maxColorValue = 255),
    `Jubilee`            = rgb(161, 165, 167, maxColorValue = 255),
    `Metropolitan`       = rgb(155,   0,  88, maxColorValue = 255),
    `Northern`           = rgb(  0,   0,   0, maxColorValue = 255),
    `Piccadilly`         = rgb(  0,  25, 168, maxColorValue = 255),
    `Victoria`           = rgb(  0, 152, 216, maxColorValue = 255),
    `Waterloo & City`    = rgb(147, 206, 186, maxColorValue = 255))

#' @rdname underground_colours
#' @export
underground_colors <- underground_colours

#' @rdname underground_colours
#' @export
underground_lines <- setNames(names(underground_colours),
                              underground_colours)
