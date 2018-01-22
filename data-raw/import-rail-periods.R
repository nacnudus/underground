# Agreed Rail Industry Periods from Freedom of Information Act request
# https://www.whatdotheyknow.com/request/136295/response/334611/attach/4/Attachment%20B.PDF.pdf

# Compared with a spreadsheet obtained privately

# Note: service days change over at 0300 hours
# The PPP review period. Any periods before the start of the PPP contracts are listed as ‘SR’ (Shadow Review).


library(tidyverse)
library(readxl)
library(lubridate)
library(tabulizer)
library(here)

url_foi <- "https://www.whatdotheyknow.com/request/136295/response/334611/attach/4/Attachment%20B.PDF.pdf"
path_foi <- here("inst", "extdata", "agreed-rail-industry-periods.pdf")

download.file(url_foi, path_foi)

x <- extract_tables(path_foi)

periods_foi <-
  x[[1]][-1:-2, ] %>%
  as_tibble() %>%
  set_names(x[[1]][2, ]) %>%
  gather(period, start_date, -1) %>%
  rename(financial_year = `Financial Year`) %>%
  mutate(financial_year = str_replace(financial_year, "-", "/"),
         start_date = dmy(start_date),
         period = as.integer(parse_number(period))) %>%
  group_by(financial_year) %>%
  arrange(financial_year, period) %>%
  mutate(end_date = lead(start_date),
         end_date = if_else(period == 13, end_date, end_date - days(1)),
         days = as.integer(interval(start_date, end_date) / days(1))) %>%
  ungroup() %>%
  filter(period != 14) %>%
  print(n = Inf)

path_private <- here("inst", "extdata", "Performance_Period_snapshot.xlsx")

periods_private <-
  read_excel(path_private, skip = 7) %>%
  select(Year, Period, Start_Date, End_Date) %>%
  set_names(c("year", "period", "start_date", "end_date")) %>%
  mutate(year = paste(year, str_sub(year + 1, 3L, 4L), sep = "/"),
         period = as.integer(period),
         start_date = as.Date(start_date),
         end_date = as.Date(end_date),
         days = as.integer(interval(start_date, end_date) / days(1))) %>%
  print(n = Inf)

# There are two disagreements:
# * 2005-06 period 13, the private source has an obvious mistake: the period
#   should end on 31 March, not 1 April.
# * 2009-10 periods 12/13, the FOI source has the boundary on 02/03 March 2010,
#   whereas the private source has it on 06/07 March 2010.  The private source
#   agrees with
#   http://dataportal.orr.gov.uk/displayreport/report/html/d986b6bf-5ca7-45c4-800c-75156d93e1a8
anti_join(periods_foi, periods_private) %>% print(n = Inf)

# Correct the mistake, and retain the 06/07 March 2010 boundary.
periods_private <-
  periods_private %>%
  mutate(end_date = if_else(end_date == ymd("2006-04-01"),
                            ymd("2006-03-31"),
                            end_date),
         days = as.integer(interval(start_date, end_date) / days(1)))

rail_periods <- periods_private

usethis::use_data(rail_periods, overwrite = TRUE)

write.csv(rail_periods, row.names = FALSE, quote = FALSE,
          file=gzfile("./inst/extdata/rail_periods.csv.gz"))
