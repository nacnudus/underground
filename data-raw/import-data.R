library(tidyverse)
library(tidyxl)
library(unpivotr)
library(lubridate)
library(here)

xlsx_url <- "https://tfl.gov.uk/cdn/static/cms/documents/lu-performance-data.xlsx"
path <- here("inst", "extdata", "lu-performance-data-almanac.xlsx")
download.file(xlsx_url, path, mode = "wb")
book <- xlsx_cells(path)
formats <- xlsx_formats(path)
sheet_names <- xlsx_sheet_names(path)
fill_rgb <- formats$local$fill$patternFill$fgColor$rgb
bold <- formats$local$font$bold

partition_sheet <- function(cells) {
  corner <-
    cells %>%
    filter(col == 2L,
           fill_rgb[local_format_id] == "FF1F497D") %>%
    arrange(row) %>%
    slice(1) %>%
    mutate(col = 1L) %>%
    select(row, col) %>%
    bind_rows(tibble(row = 2L, col = 1L))
  partition(cells, corner, strict = FALSE) %>%
    arrange(corner_row, corner_col) %>%
    transmute(partition = c("annual", "other"), cells)
}

parse_annual <- function(cells) {
  cells %>%
    behead("N", "year") %>%
    behead("W", "category") %>%
    filter(data_type == "numeric") %>%
    select(year, category, value = numeric)
}

parse_periodic <- function(cells) {
  cells %>%
    mutate(col = if_else(col == 2L & bold[local_format_id] & data_type == "character",
                         0L,
                         col)) %>%
    behead("WNW", "year") %>%
    behead("N", "period") %>%
    behead("W", "category") %>%
    filter(data_type == "numeric") %>%
    select(year, period, category, value = numeric)
}

parse_quarterly <- function(cells) {
  cells %>%
    mutate(col = if_else(col == 2L & bold[local_format_id] & data_type == "character",
                         0L,
                         col)) %>%
    behead("WNW", "year") %>%
    behead("N", "quarter") %>%
    behead("W", "category") %>%
    filter(data_type == "numeric") %>%
    select(year, quarter, category, value = numeric)
}

sheets_by_line <-
  c("Scheduled kilometres",
    "Scheduled kilometres PEAK",
    "Scheduled kilometres OFFPEAK",
    "Operated KMs",
    "Operated KMs PEAK",
    "Operated KMs OFFPEAK",
    "% Schedule operated",
    "% Schedule operated PEAK",
    "% Schedule operated OFFPEAK",
    "% of Sched. Kilometres exc. IA ",
    "Timetabled kilometres",
    "% of Timetabled Kilometres",
    "Scheduled Journey Time",
    "Total Journey Time",
    "Excess Journey Time",
    "Excess JT - excl Industrial Act",
    "AEI Time",
    "Ticket Purchase Time",
    "Platform Wait Time",
    "On Train Time",
    "Station Journey Time",
    "Train Journey Time",
    "Planned Closures Time",
    "Train Delays 15 mins",
    "Stn Closures",
    "LCH by Line",
    "Escalator Availability",
    "Lift Availability",
    "Rolling Stock MDBF",
    "Number of service cont failures",
    "Number of Track failures",
    "Passenger Journeys")

sheets_lost_customer_hours_by_category <-
  c("LCH by Category",
    "Bak LCH by Category",
    "Cen LCH by Category",
    "Cir H LCH by Category",
    "DIS LCH by Category",
    "JUB LCH by Category",
    "MET LCH by Category",
    "NOR LCH by Category",
    "PICC LCH by Category",
    "Vic LCH by Category",
    "W C LCH by Category")

sheets_customer_satisfaction_survey <-
  c("CSS Overall",
    "CSS Train Service",
    "CSS Information",
    "CSS Staff Helpfulness",
    "CSS Safety and Security",
    "CSS Cleanliness")

# There is also a sheet "Unmanned  - Open, Stations" that is small and already
# tidy, so it isn't included in this package.  A sample is below.
#
#  Month | Hours- Stations Open/Unmanned | Daily hours | Calendar Month Hours	| % Stations Open/Unmanned
# -------|-------------------------------|-------------|----------------------|-------------------------
# Jan-18 |                        245.90 |     5240.00 |            162440.00	|                    0.15%
# Feb-18 |                        142.23 |     5240.00 |            146720.00	|                    0.10%
# Mar-18 |                        201.82 |     5240.00 |            162440.00	|                    0.12%
# Apr-18 |                         90.4	 |     5240.00 |            157200.00	|                    0.06%
# May-18 |                        177.2	 |     5240.00 |            162440.00	|                    0.11%
# Jun-18 |                        229.43 |     5240.00 |            157200.00	|                    0.15%
# Jul-18 |                        254.53 |     5240.00 |            162440.00	|                    0.16%


sheets <-
  book %>%
  filter(!is_blank,
         sheet %in% c(sheets_by_line,
                      sheets_lost_customer_hours_by_category,
                      "L&E MTBF",
                      "No engineer overruns",
                      "Asset related LCH",
                      sheets_customer_satisfaction_survey)) %>%
  nest(-sheet, .key = "cells") %>%
  mutate(metric = map_chr(cells, ~ filter(.x, address == "A1")$character),
         cells = map(cells, partition_sheet)) %>%
  unnest() %>%
  spread(partition, cells)

general <-
  sheets %>%
  filter(sheet %in% sheets_by_line) %>%
  mutate(annual = map(annual, parse_annual),
         annual = map(annual, ~ rename(.x, line = category)),
         other = map(other, parse_periodic),
         other = map(other, ~ rename(.x, line = category)))

lost_customer_hours <-
  sheets %>%
  filter(sheet %in% sheets_lost_customer_hours_by_category) %>%
  mutate(annual = map(annual, parse_annual),
         other = map(other, parse_periodic))

lifts_and_escalators <-
  sheets %>%
  filter(sheet == "L&E MTBF") %>%
  mutate(annual = map(annual, parse_annual),
         annual = map(annual, ~ rename(.x, asset = category)),
         other = map(other, parse_periodic),
         other = map(other, ~ rename(.x, asset = category)))

overruns <-
  sheets %>%
  filter(sheet == "No engineer overruns") %>%
  mutate(annual = map(annual, parse_annual),
         annual = map(annual, ~ rename(.x, company = category)),
         other = map(other, parse_periodic),
         other = map(other, ~ rename(.x, company = category)))

asset_related_lost_customer_hours  <-
  sheets %>%
  filter(sheet == "Asset related LCH") %>%
  mutate(annual = map(annual, parse_annual),
         annual = map(annual, ~ rename(.x, company = category)),
         other = map(other, parse_periodic),
         other = map(other, ~ rename(.x, company = category)))

customer_satisfaction_survey <-
  sheets %>%
  filter(sheet %in% sheets_customer_satisfaction_survey) %>%
  mutate(annual = map(annual, parse_annual),
         annual = map(annual, ~ rename(.x, line = category)),
         other = map(other, parse_quarterly),
         other = map(other, ~ rename(.x, line = category)))

underground <-
  list(general,
       lost_customer_hours,
       lifts_and_escalators,
       overruns,
       asset_related_lost_customer_hours,
       customer_satisfaction_survey) %>%
  map(~ gather(.x, period, data, annual, other) %>%
        select(-period) %>%
        unnest()) %>%
  bind_rows() %>%
  select(metric, year, quarter, period, line, category, asset, company, value) %>%
  mutate(period = as.integer(period),
         line = as.character(fct_recode(as.factor(line),
                                        `Circle + H&C` = "Circle & Ham",
                                        `All Lines` = "Network MDBF",
                                        `All Lines` = "NETWORK JOURNEYS",
                                        `All Lines` = "NETWORK",
                                        `All Lines` = "Network",
                                        `All Lines` = "TOTAL ALL LINES"))) %>%
  arrange(metric, year, quarter, period, line, category, asset, company)

usethis::use_data(underground, overwrite = TRUE)

write.csv(underground, row.names = FALSE, quote = FALSE,
          file=gzfile("./inst/extdata/underground.csv.gz"))
