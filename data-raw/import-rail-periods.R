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
  rename(year = `Financial Year`) %>%
  mutate(year = str_replace(year, "-", "/"),
         start_date = dmy(start_date),
         period = as.integer(parse_number(period))) %>%
  group_by(year) %>%
  arrange(year, period) %>%
  mutate(end_date = lead(start_date),
         end_date = if_else(period == 13, end_date, end_date - days(1)),
         days = as.integer(interval(start_date, end_date) / days(1))) %>%
  ungroup() %>%
  filter(period != 14) %>%
  print(n = Inf)

# Compare with information received privately

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

# Compare with information received from the Office for Rail and Road

path_orr <- here("inst", "extdata", "Period dates.xls")

periods_orr <-
  read_excel(path_orr,
             skip = 5,
             n_max = 46 - 5,
             col_names = FALSE,
             col_types = c(rep("skip", 3),
                           "text",
                           "skip",
                           rep("date", 14))) %>%
  mutate_at(-1, as_date) %>%
  rename(year = X__1) %>%
  gather(period, start_date, -year) %>%
  mutate(year = str_replace(year, "-", "/"),
         period = as.integer(str_sub(period, 4L)) - 1L) %>%
  group_by(year) %>%
  arrange(year, period, start_date) %>%
  mutate(end_date = lead(start_date),
         end_date = if_else(period == 13, end_date, end_date - days(1)),
         days = as.integer(interval(start_date, end_date) / days(1))) %>%
  filter(period != 14L)

# There's one different boundary between periods 12 and 13 of 2009/10, where the
# FOI draws it at 2010-03-02/03 vs the ORR at 2010-03-06/07.  The ORR agrees
# with the private source.
anti_join(periods_foi, periods_orr) %>%
  left_join(periods_orr, by = c("year", "period")) %>%
  print(n = Inf)

# There's one different boundary between periods 10 and 11 of 2002/03, where the
# private source draws it at 2002-12-31/2003-01-01 vs the ORR at
# 2003-01-04/2003-01-05.  The FOI source doesn't go back this far.
anti_join(periods_private, periods_orr) %>%
  left_join(periods_orr, by = c("year", "period")) %>%
  print(n = Inf)

# I now trust the ORR source the most, so this will be the one to publish in the
# package (third time lucky?)

rail_periods <- periods_orr

usethis::use_data(rail_periods, overwrite = TRUE)

write.csv(rail_periods, row.names = FALSE, quote = FALSE,
          file=gzfile("./inst/extdata/rail_periods.csv.gz"))
