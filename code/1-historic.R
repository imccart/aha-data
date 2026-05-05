# Historic AHA reads (1980-2006) from WRDS files.
# Three vintages: 1980-1985, 1986-1993, 1994-2021 (filtered to <2007 here;
# 2007-2013 comes from per-year files in 2-yearly.R, 2014+ from 3-modern.R).

read_wrds <- function(path, year_filter = NULL) {
  d <- read_csv(path, show_col_types = FALSE, progress = FALSE) %>%
    select(any_of(aha_keep)) %>%
    mutate(
      across(any_of(aha_factor), as_factor),
      across(any_of(aha_numeric), as.numeric),
      across(any_of(aha_character), as.character)
    ) %>%
    mutate(COMMTY = case_when(
      COMMTY == 2 ~ "N",
      COMMTY == 1 ~ "Y",
      TRUE ~ NA_character_
    ))
  if ("YEAR" %in% names(d)) d <- rename(d, year = YEAR)
  if (!is.null(year_filter)) d <- filter(d, year < year_filter)
  d
}

aha.data.1980 <- read_wrds("data/input/AHA Data/AHA FY 1980-1985/ANNUAL_SURVEY_HIST_1980_1985.csv")
aha.data.1986 <- read_wrds("data/input/AHA Data/AHA FY 1986-1993/ANNUAL_SURVEY_HIST_1986_1993.csv")
aha.data.1994 <- read_wrds("data/input/AHA Data/AHA FY 1994-2021/ANNUAL_SURVEY_HIST_1994_RECENT.csv",
                           year_filter = 2007)

aha.historic <- bind_rows(aha.data.1980, aha.data.1986, aha.data.1994)
