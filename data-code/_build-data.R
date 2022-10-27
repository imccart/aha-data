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

## Find changes/reasons (aha-data) ---------------------------------
# aha-data-y contains all (ID,year) pair in df_hosp.
# If there is no change, aha-data$del == NA & aha-data$add == NA.

aha_data <- tibble()  # modify this later
for (y in 2007:2019) {
  source('data-code/aha-data-y.R')
  aha_data <- bind_rows(aha_data, df_year)
  rm(list = c('df_year'))
}
source('data-code/tidy_aha_data.R')

aha_data <- aha_data %>% 
  filter(!is.na(reason_short)) %>%
  select(ID,year,reason_short,reason, everything()) %>%
  arrange(year)

## add changes to unique hospital ID -----------------------------
# error_counter <- 0  # check data_right[error_counter,]
# df_left_test <- aha_data
# del2007 <- 'haha'
# err <- 0

my_update <- function(data_left, data_right) {
  for (i_right in 1:nrow(data_right)) {  # for each ID in right
    # error_counter <<- i_right+1
    ID <- data_right[[i_right,'ID']]
    
    if (is.na(data_right[[i_right, 'del']])==F & 
        data_right[[i_right, 'year']]==2007 &
        !(ID %in% data_left$ID)) {
      # del2007 <<- 'if'
      row <- data.frame('ID'=ID,
                        'year1'=2007,
                        'reason_short1'=data_right[[i_right,'reason_short']],
                        'reason1'=data_right[[i_right,'reason']])
      data_left <- bind_rows(row, data_left)
      # df_left_test <<- data_left
    } else {
      # del2007 <<- 'else'
      i_left <- which(data_left$ID == ID)   # find index in left
      # err <<- 1
      
      # find empty slot in left
      suffix <- 1 
      reason_s <- paste0('reason_short',suffix)
      while (is.na(data_left[[i_left,reason_s]]) == F) { 
        suffix <- suffix+1
        reason_s <- paste0('reason_short',suffix)
      }
      #vars = c('reason')
      vars = c('year', 'reason_short','reason', 'MNAME')  # modify here
      for (v in vars) {
        v_s <- paste0(v, suffix)
        data_left[i_left, v_s] <- data_right[i_right, v]
        #df_left_test <<- data_left
      }
    }
  }
  return(data_left)
}

# aha_data %>% group_by(ID) %>% summarise(n=n()) %>% arrange(desc(n))
# maximum number of changes = 4

df_change <- df_hosp %>% select(ID) %>% unique() %>%
  mutate('year1' = NA, 'reason_short1' = NA, 'reason1' = NA,
         'year2' = NA, 'reason_short2' = NA, 'reason2' = NA,
         'year3' = NA, 'reason_short3' = NA, 'reason3' = NA,
         'year4' = NA, 'reason_short4' = NA, 'reason4' = NA,
         'year5' = NA, 'reason_short5' = NA, 'reason5' = NA,
         'MNAME1'=NA,'MNAME2'=NA,'MNAME3'=NA,'MNAME4'=NA,'MNAME5'=NA) %>%
  mutate(ID2 = as.integer(ID),
         ID = ifelse(is.na(ID2)==F, ID2, ID)) %>%
  select(-c(ID2))
# fifth is just a buffer
# ID is for sth like 123.0 -> 123. There are 12B,12C, too.

aha_data <- aha_data %>% 
  mutate(ID2 = as.integer(ID),
         ID = ifelse(is.na(ID2)==F, ID2, ID)) %>%
  select(-c(ID2))

df_change <- my_update(df_change, aha_data)

## add merge/demerge/dissolution ID ------------------------------------

# df_change %>% select(reason_short1) %>% unique()
# 'merged into', 'unit of other hosp', 'dissolution', 'demerger',
# 'demerged', 'duplicate', 'merger result', 'ID change'

# for (suffix in 1:5) {}
df_change %>% filter(reason_short1 == 'merged into') %>% select(reason1)

