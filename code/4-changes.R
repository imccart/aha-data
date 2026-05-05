# Manually-collected Summary of Changes data (1986-2019).
# Mirrors the legacy logic in data-code/_aha-data.R: build a long
# change file out of closures + mergers + new-hospitals + other-changes,
# applying year-1 to event years (the "year" column in the source files
# is when the change appears in the survey, so the actual event year is
# year - 1, except for new-hospital additions).

changes_dir <- "data/input/AHA Data/AHA Summary of Changes 1986-2019"

aha.closures.historic <- read_csv(file.path(changes_dir, "closures.csv"),
                                  show_col_types = FALSE, progress = FALSE) %>%
  select(ID, year, reason, change_type) %>%
  mutate(year = year - 1, ID = as.character(ID))

aha.merger.historic <- read_csv(file.path(changes_dir, "mergers.csv"),
                                show_col_types = FALSE, progress = FALSE) %>%
  select(ID, year, reason, change_type) %>%
  group_by(ID, year) %>%
  filter(row_number() == 1) %>%
  ungroup() %>%
  mutate(year = year - 1, ID = as.character(ID))

aha.new.historic <- read_csv(file.path(changes_dir, "new-hospitals.csv"),
                             show_col_types = FALSE, progress = FALSE) %>%
  mutate(ID = as.character(ID))

aha.other.historic <- read_csv(file.path(changes_dir, "other-changes.csv"),
                               show_col_types = FALSE, progress = FALSE) %>%
  select(ID, year, reason, change_type) %>%
  mutate(year = year - 1, ID = as.character(ID))

aha.changes <- bind_rows(
    aha.closures.historic,
    aha.merger.historic,
    aha.new.historic,
    aha.other.historic
  ) %>%
  arrange(ID, year) %>%
  group_by(ID) %>%
  mutate(change_count = row_number()) %>%
  ungroup() %>%
  mutate(change_source1 = "Summary of Changes")
