# Modern AHA reads (2014-2024) from the single combined file.
# File contains ~1,987 columns; we subset to aha_keep. latin1 encoding
# is required (UTF-8 fails on Mayagüez and other non-ASCII city names).

aha_2014_zip <- "data/input/AHA Data/aha-2014-2024.zip"
aha_2014_csv <- unzip(aha_2014_zip, list = TRUE)$Name[1]

aha.modern.new <- read_csv(
    unz(aha_2014_zip, aha_2014_csv),
    show_col_types = FALSE,
    progress = FALSE,
    locale = locale(encoding = "latin1"),
    guess_max = 50000
  ) %>%
  select(any_of(aha_keep)) %>%
  rename(year = YEAR) %>%
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
