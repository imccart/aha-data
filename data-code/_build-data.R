# Meta --------------------------------------------------------------------
## Title:         Hospital Landscape Data from AHA
## Author:        Ian McCarthy, Wonjun Choi
## Date Created:  9/2/2022
## Date Edited:   9/29/2022

# Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, tidyverse, janitor, here)

# Load full list of hospitals --------------------------------------------
# working directory is {}/aha-data/ (above data-code)
df_hosp <- tibble()
for (y in 2007:2019){
  if (y == 2007) {
    f <- here("data",'input',paste0('AHA FY ',y),'COMMA','comma.csv')
  } else if (y==2008) {
    f <- here('data','input',paste0('AHA FY ',y),'COMMA','pubas08.csv')
  } else if (y==2009) {
    f <- here('data','input',paste0('AHA FY ',y),'Comma','pubas09.csv')
  } else if (y<=2012) {
    f <- here('data','input',paste0('AHA FY ',y),
              'COMMA', paste0('ASPUB',y-2000,'.csv'))
  } else if (y<=2015) {
    f <- here('data','input',paste0('AHA FY ',y),
              'COMMA', paste0('ASPUB',y-2000,'.CSV'))
  } else {
    f <- here('data','input',paste0('AHA FY ',y),
              paste0('ASPUB',y-2000,'.csv'))
  }
  df_temp <- read.csv(f)
  df_temp <- df_temp %>% select('ID','MNAME') %>% mutate(year=y)
  df_hosp <- rbind(df_hosp, df_temp)
}
df_hosp <- df_hosp %>% group_by(ID) %>% 
  mutate(n = n()) %>% ungroup()

# Find changes/reasons --------------------------------------------------

# Outline of the current data-building scheme
# 1. Make a full (long*) list of hosp-year (done above: df_hosp)
#    * what's better: long? wide?
#    !! should be year by year (otherwise, left_join is troublesome)
# 1. Subset the full-list from df_hosp
# 2. Using sum of changes, for each year, 
#    create 2 data frames: for addition, deletion
# 3. For addition, create a dummy for each reason, but drop status/Status
# 4. left_join 3 into df_hosp using (ID,year)*
#    * we also have state, city, hospital name
#      -- city, hospital name is not valid (problems in pdf to csv)
# 5. For deletion, create a dummy, but drop status/Status
# 6. add (NOT left_join) ID,year to df_hosp with reason
# 7. If demerged/merged/etc, from where?
# 8. Repeat and bind_rows()

aha_data <- tibble()  # modify this later
for (y in 2007:2019) {
  source(paste0('data-code/add-change-y.R'))
  aha_data <- bind_rows(aha_data, df_year)
}

## Tidy aha_data
# status changes nonreg <-> reg : discard those changes
aha_data %>% 
  filter(readum_from==1 | 
           readum_Previously|
           readum_STATUS==1) %>%
  select(ID,year,add,del,reason)
aha_data <- aha_data %>% 
  select(-c(readum_from, readum_Previously, readum_STATUS))

# Code for: 7. If demerged, from where?
#   df_temp <- df %>% filter(demerged == 1) %>%
#     select(ID, REASON.FOR.ADDITION)
#   df_temp$demerged_from = lapply(df_temp$REASON.FOR.ADDITION, spl_last)