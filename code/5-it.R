# AHA IT Supplement panel (2008-2024).
# Two source files cover non-overlapping years (with an overlap in 2022,
# resolved in favor of the newer release):
#   * IT_SURVEY.csv               UPPERCASE columns; covers 2008-2020 + 2022
#   * aha-it-2014-2024.zip        lowercase columns; covers 2022-2024
# Use IT_SURVEY for 2008-2021 and the zip for 2022-2024.

it_legacy_path <- "data/input/AHA Data/IT-supplement/IT_SURVEY.csv"
it_recent_zip  <- "data/input/AHA Data/IT-supplement/aha-it-2014-2024.zip"
it_recent_csv  <- unzip(it_recent_zip, list = TRUE)$Name[1]

aha.it.legacy <- read_csv(
    it_legacy_path,
    show_col_types = FALSE, progress = FALSE,
    locale = locale(encoding = "latin1"),
    guess_max = 50000
  ) %>%
  rename_with(toupper) %>%
  rename(year = YEAR) %>%
  filter(year <= 2021)

aha.it.recent <- read_csv(
    unz(it_recent_zip, it_recent_csv),
    show_col_types = FALSE, progress = FALSE,
    locale = locale(encoding = "latin1"),
    guess_max = 50000
  ) %>%
  rename_with(toupper) %>%
  rename(year = YEAR) %>%
  filter(year >= 2022)

aha.it <- bind_rows(aha.it.legacy, aha.it.recent) %>%
  arrange(ID, year)
