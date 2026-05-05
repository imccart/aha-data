# Yearly AHA reads (2007-2013) from per-year COMMA files.
# Path conventions vary across years (folder casing, filename, etc.).

aha_yearly_path <- function(y) {
  if (y == 2007) {
    "data/input/AHA Data/AHA FY 2007/COMMA/comma.csv"
  } else if (y == 2008) {
    "data/input/AHA Data/AHA FY 2008/COMMA/pubas08.csv"
  } else if (y == 2009) {
    "data/input/AHA Data/AHA FY 2009/Comma/pubas09.csv"
  } else if (y <= 2012) {
    paste0("data/input/AHA Data/AHA FY ", y, "/COMMA/ASPUB", y - 2000, ".csv")
  } else {
    paste0("data/input/AHA Data/AHA FY ", y, "/COMMA/ASPUB", y - 2000, ".CSV")
  }
}

aha.modern.yearly <- tibble()
for (y in 2007:2013) {
  aha.year <- read_csv(aha_yearly_path(y), show_col_types = FALSE, progress = FALSE) %>%
    select(any_of(aha_keep)) %>%
    mutate(year = y) %>%
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
  aha.modern.yearly <- bind_rows(aha.modern.yearly, aha.year)
}
