# not a hosp
sum_of_change <- sum_of_change %>%
  mutate(reason_short = NA) %>% 
  mutate(reason_short = 
           ifelse(!is.na(readum_Inpatient) | !is.na(readum_Ambulatory) |
                    !is.na(readum_Outpatient) | !is.na(readum_Hospice) |
                    !is.na(readum_Not) | !is.na(readum_Psychiatric) | 
                    !is.na(readum_Behavioral)| !is.na(readum_Nursing) | 
                    !is.na(readum_Rehabilitation) | !is.na(readum_Urgent) | 
                    !is.na(readum_Skilled) | !is.na(readum_Developmental) | 
                    !is.na(readum_BEHAVIORAL) | !is.na(readum_RESIDENTIAL) | 
                    !is.na(readum_REHABILITATION) | !is.na(readum_SKILLED) |
                    !is.na(`readum_Merged/Ambulatory`) | 
                    !is.na(`readum_Emergency/Urgent`) |
                    !is.na(readum_Residential)| !is.na(readum_Emergency) | 
                    !is.na(readum_Substance),
                  'not a hosp',reason_short)) %>%
  select(-c(readum_Inpatient, readum_Ambulatory, readum_Outpatient,
            readum_Hospice, readum_Not, readum_Psychiatric,readum_Behavioral,
            readum_Nursing, readum_Rehabilitation, readum_Urgent,
            readum_Skilled, readum_Developmental,readum_BEHAVIORAL,
            readum_RESIDENTIAL, readum_REHABILITATION,readum_SKILLED,
            `readum_Merged/Ambulatory`, `readum_Emergency/Urgent`,
            readum_Residential,readum_Emergency, readum_Substance))

sum_of_change <- sum_of_change %>%
  mutate(reason_short =
           ifelse(!is.na(readum_Unit), 'unit of other hosp',reason_short)) %>%
  select(-readum_Unit)

# merge/demerge
sum_of_change <- sum_of_change %>%
  mutate(reason_short =
           ifelse(!is.na(readum_Merged)|!is.na(`readum_Merged/closed`)|
                    !is.na(`readum_Merged/Closed`)|
                    !is.na(`readum_Closed/Merged`)|
                    !is.na(readum_MERGED)| !is.na(readum_Changed),
                  'merged into',reason_short)) %>%
  select(-c(readum_Merged,`readum_Merged/closed`,`readum_Merged/Closed`,
            `readum_Closed/Merged`,readum_MERGED,readum_Changed))

sum_of_change <- sum_of_change %>%
  mutate(reason_short =
           ifelse(!is.na(readum_Merger) | !is.na(readum_Result),
                  'merger result', reason_short)) %>%
  select(-c(readum_Merger, readum_Result))

sum_of_change <- sum_of_change %>%
  mutate(reason_short = 
           ifelse(!is.na(readum_Demerged),'demerged',reason_short)) %>%
  select(-readum_Demerged)

sum_of_change <- sum_of_change %>%
  mutate(reason_short = 
           ifelse(!is.na(readum_Demerger),'demerger',reason_short)) %>%
  select(-readum_Demerger)

sum_of_change <- sum_of_change %>%
  mutate(reason_short =
           ifelse(!is.na(`readum_Dissolution*`),
                  'dissolution',reason_short)) %>%
  select(-`readum_Dissolution*`)

# newly added, open, reopen
sum_of_change <- sum_of_change %>%
  # filter(!(reason=='Newly Registered'|
  #            reason=='Newly registered'|
  #            reason=='Newly added to the registered file')) %>%
  mutate(reason_short =
           ifelse(reason=='Newly added'|reason=='Newly Added'|
                    !is.na(readum_nNoenwrleyg),
                  'newly added',reason_short)) %>%
  select(-c(readum_Newly, readum_nNoenwrleyg))

sum_of_change <- sum_of_change %>%
  mutate(reason_short = 
           ifelse(!is.na(readum_Reopened), 'reopened',reason_short)) %>%
  select(-readum_Reopened)

sum_of_change <- sum_of_change %>%
  mutate(reason_short = 
           ifelse(!is.na(readum_Formerly) | (!is.na(readum_Previously) & year==2019),
                  'formerly sth else',reason_short)) %>%
  select(-c(readum_Formerly,readum_Previously))

# closed
sum_of_change <- sum_of_change %>%
  mutate(reason_short =
           ifelse(!is.na(readum_Closed)| !is.na(readum_CLOSED),
                  'closed',reason_short)) %>%
  select(-c(readum_Closed, readum_CLOSED))

sum_of_change <- sum_of_change %>%
  mutate(reason_short = 
           ifelse(!is.na(readum_Temporarily),
                  'temporarily closed',reason_short)) %>%
  select(-readum_Temporarily)

# etc
sum_of_change <- sum_of_change %>% 
  mutate(reason_short =
           ifelse(!is.na(readum_ID) | !is.na(readum_System) | 
                    !is.na(`readum_change-formerly`),
                  'ID change',reason_short)) %>%
  select(-c(readum_ID, readum_System, `readum_change-formerly`))

sum_of_change <- sum_of_change %>% 
  mutate(reason_short = 
           ifelse(!is.na(readum_Duplicate), 'duplicate', reason_short)) %>%
  select(-readum_Duplicate)

sum_of_change <- sum_of_change %>%
  select(-c(readum_from, readum_STATUS))  # ignore(register <-> nonregister)

# idk
sum_of_change <- sum_of_change %>% 
  mutate(reason_short =
           ifelse(!is.na(`readum_Demerged-Merger`) |
                    !is.na(readum_Nonregistered),
                  'idk',reason_short)) %>%
  select(-c(`readum_Demerged-Merger`,readum_Nonregistered))