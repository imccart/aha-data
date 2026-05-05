# Combine all year sources, derive constructed variables, impute missing
# geo from adjacent years, merge change history, and write outputs to
# data/output/update-2026/.

aha.final <- bind_rows(aha.historic, aha.modern.yearly, aha.modern.new) %>%
  mutate(
    critical_access = case_when(
      year < 2003 ~ NA_real_,
      year >= 2003 & year < 2009 & CAH == 2 ~ 0,
      year >= 2003 & year < 2009 & CAH == 1 ~ 1,
      year >= 2009 & MAPP18 == 2 ~ 0,
      year >= 2009 & MAPP18 == 1 ~ 1,
      TRUE ~ 0
    ),
    own_type = between(CNTRL, 12, 16) +
      2 * between(CNTRL, 21, 23) +
      3 * between(CNTRL, 30, 33) +
      4 * between(CNTRL, 41, 48),
    own_gov    = ifelse(own_type == 1, 1, 0),
    own_nfp    = ifelse(own_type == 2, 1, 0),
    own_profit = ifelse(own_type == 3, 1, 0),
    teach_major = case_when(
      MAPP8 == 1 ~ 1,
      TRUE ~ 0
    ),
    teach_minor = case_when(
      MAPP3 == 1 | MAPP5 == 1 | MAPP8 == 1 | MAPP12 == 1 | MAPP13 == 1 ~ 1,
      TRUE ~ 0
    ),
    system = ifelse(!is.na(SYSID) | MHSMEMB == 1, 1, 0)
  ) %>%
  filter(!is.na(ID), ID != "", ID != "1111111") %>%
  select(-c(CAH, MAPP18))


# Forward-/back-fill missing values where adjacent years agree --------

factor_cols <- names(aha.final)[sapply(aha.final, is.factor)]

aha.final.edit <- aha.final %>%
  mutate(across(all_of(factor_cols), as.character))

aha.final.lag  <- aha.final.edit %>% mutate(year = year + 1)
aha.final.lead <- aha.final.edit %>% mutate(year = year - 1)

merged_data <- aha.final.edit %>%
  left_join(aha.final.lag,  by = c("ID", "year"), suffix = c("", ".lag")) %>%
  left_join(aha.final.lead, by = c("ID", "year"), suffix = c("", ".lead"))

merged_data <- merged_data %>%
  mutate(across(
    .cols = all_of(names(aha.final.edit)[!names(aha.final.edit) %in% c("ID", "year")]),
    .fns = ~ case_when(
      is.na(.) &
        !is.na(get(paste0(cur_column(), ".lag"))) &
        !is.na(get(paste0(cur_column(), ".lead"))) &
        get(paste0(cur_column(), ".lag")) == get(paste0(cur_column(), ".lead")) ~
        get(paste0(cur_column(), ".lag")),
      TRUE ~ .
    )
  ),
  MLOCZIP = case_when(
    year == 1983 & substr(MLOCZIP, 1, 4) ==
      substr(MLOCZIP.lag, nchar(MLOCZIP.lag) - 3, nchar(MLOCZIP.lag)) ~ MLOCZIP.lag,
    year == 1983 & substr(MLOCZIP, 1, 4) ==
      substr(MLOCZIP.lead, nchar(MLOCZIP.lead) - 3, nchar(MLOCZIP.lead)) ~ MLOCZIP.lead,
    year == 1983 & is.na(MLOCZIP) ~ NA_character_,
    TRUE ~ MLOCZIP
  ))

merged_data <- merged_data %>%
  arrange(ID, year) %>%
  group_by(ID) %>%
  fill(c(MLOCZIP, MLOCCITY, MSTATE, COMMTY, SERV,
         LAT, LONG, HRRCODE, HRRNAME, HSACODE, HSANAME),
       .direction = "updown") %>%
  ungroup()

aha.final <- merged_data %>%
  select(names(aha.final.edit)) %>%
  mutate(across(all_of(factor_cols), as.factor))


# Merge change history -------------------------------------------------

aha.id.years <- aha.final %>%
  select(ID, year) %>%
  group_by(ID) %>%
  mutate(first_year = min(year), last_year = max(year)) %>%
  ungroup() %>%
  select(ID, first_year, last_year) %>%
  distinct()

aha.survey.changes <- aha.id.years %>%
  filter(last_year < max(aha.final$year)) %>%
  select(ID, year = last_year) %>%
  distinct(ID, year) %>%
  mutate(change_source2 = "AHA Survey IDs")

aha.combine <- aha.final %>%
  left_join(aha.changes, by = c("ID", "year")) %>%
  left_join(aha.survey.changes, by = c("ID", "year")) %>%
  mutate(change_source = case_when(
    !is.na(change_source1) & is.na(change_source2)  ~ "Summary of Changes",
    is.na(change_source1)  & !is.na(change_source2) ~ "AHA Survey ID",
    !is.na(change_source1) & !is.na(change_source2) ~ "Both",
    is.na(change_source1)  & is.na(change_source2)  ~ "No Change"
  )) %>%
  select(-change_source1, -change_source2)


# Write outputs --------------------------------------------------------

dir.create("data/output/update-2026", showWarnings = FALSE, recursive = TRUE)

write_csv(aha.combine, "data/output/update-2026/aha_data.csv")

aha.combine %>%
  select(ID, SYSID, MCRNUM, NPINUM, LAT, LONG, FCNTYCD, FSTCD,
         MLOCCITY, MLOCZIP, MSTATE, MLOCAD1, MLOCAD2, year,
         own_type, critical_access, change_type) %>%
  write_csv("data/output/update-2026/aha_geo.csv")

write_csv(aha.it, "data/output/update-2026/aha_it.csv")

message("Wrote ", nrow(aha.combine), " rows to data/output/update-2026/aha_data.csv (", min(aha.combine$year), "-", max(aha.combine$year), ")")
message("Wrote ", nrow(aha.it), " rows to data/output/update-2026/aha_it.csv (", min(aha.it$year), "-", max(aha.it$year), ")")
