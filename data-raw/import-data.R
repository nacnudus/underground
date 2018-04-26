library(tidyverse)
library(tidyxl)
library(readxl)
library(unpivotr)
library(directlabels)
library(lubridate)
library(here)

xlsx_url <- "https://tfl.gov.uk/cdn/static/cms/documents/lu-performance-data-almanac.xlsx"
path <- here("inst", "extdata", "lu-performance-data-almanac.xlsx")
download.file(xlsx_url, path, mode = "wb")
book <- xlsx_cells(path)
formats <- xlsx_formats(path)
sheet_names <- xlsx_sheet_names(path)

annually <- function(cells) {
  metric <- filter(cells, address == "A1")$character
  year <-
    cells %>%
    filter(row == 2, col >= 2, !is.na(character)) %>%
    select(row, col, year = character)
  category <-
    cells %>%
    filter(row >= 3L, col == 1L) %>%
    arrange(row) %>%
    mutate(bold = formats$local$font$bold[local_format_id]) %>%
    filter(!lag(as.logical(cumsum(bold)), default = FALSE)) %>%
    select(row, col, category = character)
  datacells <-
    cells %>%
    filter(row %in% unique(category$row),
           col >= 2,
           !is.na(numeric)) %>%
    select(row, col, value = numeric)
  datacells %>%
    mutate(metric = metric) %>%
    W(category) %>%
    N(year) %>%
    select(-row, -col)
}

four_weekly <- function(cells, first_row) {
  metric <- filter(cells, address == "A1")$character
  period <-
    cells %>%
    filter(row == first_row, col >= 2, !is.na(numeric)) %>%
    select(row, col, period = numeric) %>%
    mutate(period = as.integer(period))
  year <-
    cells %>%
    filter(row >= first_row + 1,
           formats$local$alignment$horizontal[local_format_id] == "centerContinuous",
           !is.na(formats$local$border$bottom$style[local_format_id]),
           !is.na(character)) %>%
    select(row, col, year = character)
  category <-
    cells %>%
    filter(col == 1,
           !is.na(character)) %>%
    select(row, col, category = character)
  datacells <-
    cells %>%
    filter(row >= first_row + 1,
           col >= 2,
           formats$local$alignment$horizontal[local_format_id] != "centerContinuous",
           !is.na(numeric)) %>%
    select(row, col, value = numeric)
  datacells %>%
    mutate(metric = metric) %>%
    W(category) %>%
    WNW(year) %>% # trick to 'chunk' by treating a column header as a row header
    N(period) %>%
    select(-row, -col)
}

quarterly <- function(cells, first_row) {
  metric <- filter(cells, address == "A1")$character
  quarter <-
    cells %>%
    filter(row == first_row, col >= 2, !is.na(character)) %>%
    select(row, col, quarter = character)
  year <-
    cells %>%
    filter(row >= first_row + 1,
           formats$local$alignment$horizontal[local_format_id] == "centerContinuous",
           !is.na(formats$local$border$bottom$style[local_format_id]),
           !is.na(character)) %>%
    select(row, col, year = character)
  category <-
    cells %>%
    filter(col == 1,
           !is.na(character)) %>%
    select(row, col, category = character)
  datacells <-
    cells %>%
    filter(row >= first_row + 1,
           col >= 2,
           formats$local$alignment$horizontal[local_format_id] != "centerContinuous",
           !is.na(numeric)) %>%
    select(row, col, value = numeric)
  datacells %>%
    mutate(metric = metric) %>%
    W(category) %>%
    WNW(year) %>% # trick to 'chunk' by treating a column header as a row header
    N(quarter) %>%
    select(-row, -col)
}


sheets_by_line <-
  c("Scheduled kilometres",
    "Scheduled kilometres PEAK",
    "Scheduled kilometres OFFPEAK",
    "Operated KMs",
    "Operated KMs PEAK old",
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

# From https://en.wikipedia.org/wiki/Talk%3ATransport_for_London
#
# BCV = Bakerloo, Central, Victoria (and Waterlool & City)
# SSL = Sub-Surface Lines (District, Hammersmith and City, Metropolitan, Circle
#       and East London)
# JNP = Jubilee, Northern, Picadilly
#
# "The maintenance and upgrading of the London Underground Network is carried
# out by different companies. Tube Lines in responsible for the Jubilee,
# Northern and Piccadilly Lines (JNP), Metronet BCV is responsible for the
# Bakerloo, Central and Victoria Lines (BCV) as well as the Waterloo and City
# Line, whilst Metronet SSL (sub surface lines) is responsible for the District,
# Hammersmith and City, Metropolitan, Circle and East London lines." DavidB601
# 20:57, 7 November 2006 (UTC)

general_four_weekly <-
  book %>%
  filter(sheet %in% sheets_by_line) %>%
  nest(-sheet) %>%
  transmute(data = map(data, four_weekly, first_row = 14)) %>%
  unnest() %>%
  rename(line = category)
general_annually <-
  book %>%
  filter(sheet %in% sheets_by_line) %>%
  nest(-sheet) %>%
  transmute(data = map(data, annually)) %>%
  unnest() %>%
  rename(line = category)

lost_customer_hours_by_category_four_weekly <-
  book %>%
  filter(sheet %in% sheets_lost_customer_hours_by_category) %>%
  nest(-sheet) %>%
  transmute(data = map(data, four_weekly, first_row = 26)) %>%
  unnest()
lost_customer_hours_by_category_annually <-
  book %>%
  filter(sheet %in% sheets_lost_customer_hours_by_category) %>%
  nest(-sheet) %>%
  transmute(data = map(data, annually)) %>%
  unnest()

lifts_and_escalators_four_weekly <-
  book %>%
  filter(sheet == "L&E MTBF") %>%
  nest(-sheet) %>%
  transmute(data = map(data, four_weekly, first_row = 12)) %>%
  unnest() %>%
  rename(asset = category)
lifts_and_escalators_annually <-
  book %>%
  filter(sheet == "L&E MTBF") %>%
  nest(-sheet) %>%
  transmute(data = map(data, annually)) %>%
  unnest() %>%
  rename(asset = category)

asset_related_lost_customer_hours_four_weekly <-
  book %>%
  filter(sheet == "Asset related LCH") %>%
  nest(-sheet) %>%
  transmute(data = map(data, four_weekly, first_row = 13)) %>%
  unnest() %>%
  rename(company = category)
asset_related_lost_customer_hours_annually  <-
  book %>%
  filter(sheet == "Asset related LCH") %>%
  nest(-sheet) %>%
  transmute(data = map(data, annually)) %>%
  unnest() %>%
  rename(company = category)

engineering_overruns_four_weekly <-
  book %>%
  filter(sheet == "No engineer overruns") %>%
  nest(-sheet) %>%
  transmute(data = map(data, four_weekly, first_row = 14)) %>%
  unnest() %>%
  rename(company = category)
engineering_overruns_annually <-
  book %>%
  filter(sheet == "No engineer overruns") %>%
  nest(-sheet) %>%
  transmute(data = map(data, annually)) %>%
  unnest() %>%
  rename(company = category)

customer_satisfaction_survey_quarterly <-
  book %>%
  filter(sheet %in% sheets_customer_satisfaction_survey) %>%
  nest(-sheet) %>%
  transmute(data = map(data, quarterly, first_row = 14)) %>%
  unnest() %>%
  rename(line = category)
customer_satisfaction_survey_annually <-
  book %>%
  filter(sheet %in% sheets_customer_satisfaction_survey) %>%
  nest(-sheet) %>%
  transmute(data = map(data, annually)) %>%
  unnest() %>%
  rename(line = category)

underground <-
  bind_rows(general_four_weekly,
            engineering_overruns_four_weekly,
            asset_related_lost_customer_hours_four_weekly,
            lifts_and_escalators_four_weekly,
            lost_customer_hours_by_category_four_weekly,
            customer_satisfaction_survey_quarterly,
            general_annually,
            engineering_overruns_annually,
            asset_related_lost_customer_hours_annually,
            lifts_and_escalators_annually,
            lost_customer_hours_by_category_annually,
            customer_satisfaction_survey_annually) %>%
  select(metric, year, quarter, period, line, category, asset, company, value) %>%
  mutate(line = as.character(fct_recode(as.factor(line),
                                        `Circle + H&C` = "Circle & Ham",
                                        `All Lines` = "Network MDBF",
                                        `All Lines` = "NETWORK JOURNEYS",
                                        `All Lines` = "NETWORK",
                                        `All Lines` = "Network",
                                        `All Lines` = "TOTAL ALL LINES")))

usethis::use_data(underground, overwrite = TRUE)

write.csv(underground, row.names = FALSE, quote = FALSE,
          file=gzfile("./inst/extdata/underground.csv.gz"))
