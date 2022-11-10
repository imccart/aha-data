# Meta --------------------------------------------------------------------
## Title:         Hospital Landscape Data from AHA
## Author:        Ian McCarthy, Wonjun Choi
## Date Created:  9/2/2022
## Date Edited:   11/09/2022

## Overview:
##     1. In the first block, I generate `df_hosp`, which contains
##        every hospital information in AHA data.
##     2. In the second block, I generate `sum_of_change`, which contains
##        the changes from the 'summary of changes'.
##     3. In the third block, I combine 1 and 2 into `df_change`.
##     4. In the fourth block, I add `ID1`-`ID5` in `df_change`.

# Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, tidyverse, janitor, here)

# Load full list of hospitals --------------------------------------------
# df_hosp contains all (ID,year) pairs. No hospital info.

df_hosp <- tibble()
for (y in 2007:2019){
  if (y == 2007) {
    # working directory is {}/aha-data/ (above data-code)
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
rm(list=c('df_temp'))
df_hosp <- df_hosp %>% group_by(ID) %>% 
  mutate(n = n()) %>% ungroup()

## Find changes/reasons (sum_of_change) ---------------------------------
# sum_of_change contains all changes.
# If there is no change, sum_of_change$del == NA & sum_of_change$add == NA.

sum_of_change <- tibble()  # modify this later
for (y in 2007:2019) {
  source('data-code/sum_of_change-y.R')  # this creates `df_year`
  sum_of_change <- bind_rows(sum_of_change, df_year)
  rm(list = c('df_year'))
}
source('data-code/tidy_sum_of_change.R')

sum_of_change <- sum_of_change %>% 
  filter(!is.na(reason_short)) %>%
  select(ID,year,reason_short,reason, everything()) %>%
  arrange(year)

## add changes to unique hospital ID -----------------------------
# my_update is a function that add the changes in sum_of_change to df_hosp

# error_counter <- 0  # check data_right[error_counter,]
# df_left_test <- sum_of_change
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

# sum_of_change %>% group_by(ID) %>% summarise(n=n()) %>% arrange(desc(n))
# maximum number of changes = 4
# fifth is just a buffer

df_change <- df_hosp %>% select(ID) %>% unique() %>%
  mutate('year1' = NA, 'reason_short1' = NA, 'reason1' = NA,
         'year2' = NA, 'reason_short2' = NA, 'reason2' = NA,
         'year3' = NA, 'reason_short3' = NA, 'reason3' = NA,
         'year4' = NA, 'reason_short4' = NA, 'reason4' = NA,
         'year5' = NA, 'reason_short5' = NA, 'reason5' = NA,
         'MNAME1'=NA,'MNAME2'=NA,'MNAME3'=NA,'MNAME4'=NA,'MNAME5'=NA) %>%
  mutate(ID2 = as.integer(ID),  # e.g. 123456B, 1234567.0
         ID = ifelse(is.na(ID2)==F, ID2, ID)) %>%
  select(-c(ID2))

sum_of_change <- sum_of_change %>% 
  mutate(ID2 = as.integer(ID),
         ID = ifelse(is.na(ID2)==F, ID2, ID)) %>%
  select(-c(ID2))

df_change <- my_update(df_change, sum_of_change)
# rm(list=c('sum_of_change'))

## add merge/demerge/dissolution ID ------------------------------------
# So far, df_change has the history of changes, but not related IDs:
# If 1234567 is merged into 9876543, add this ID's to the df.

# df_change %>% select(reason_short1) %>% unique()
# 'merged into', 'unit of other hosp', 'dissolution', 'demerger',
# 'demerged', 'duplicate', 'merger result', 'ID change'

# for (suffix in 1:5) {}
df_change <- df_change %>%
  mutate(target = reason1) %>%
  mutate(target = gsub('Merged with ([0-9]+) to form','',target)) %>%
  mutate(target = gsub('Changed to outpatient and merged with ([0-9]+) to form','',target)) %>%
  mutate(target = parse_number(target)) %>%
  rename(ID1 = target)
  
df_change <- df_change %>%
  mutate(target = reason2) %>%
  mutate(target = gsub('Merged with ([0-9]+) to form','',target)) %>%
  mutate(target = gsub('Changed to outpatient and merged with ([0-9]+) to form','',target)) %>%
  mutate(target = parse_number(target)) %>%
  rename(ID2 = target)

df_change <- df_change %>%
  mutate(target = reason3) %>%
  mutate(target = gsub('Merged with ([0-9]+) to form','',target)) %>%
  mutate(target = gsub('Changed to outpatient and merged with ([0-9]+) to form','',target)) %>%
  mutate(target = parse_number(target)) %>%
  rename(ID3 = target)

df_change <- df_change %>%
  mutate(target = reason4) %>%
  mutate(target = gsub('Merged with ([0-9]+) to form','',target)) %>%
  mutate(target = gsub('Changed to outpatient and merged with ([0-9]+) to form','',target)) %>%
  mutate(target = parse_number(target)) %>%
  rename(ID4 = target)

df_change <- df_change %>%
  select(ID,year1,reason_short1,ID1,reason1,MNAME1,
            year2,reason_short2,ID2,reason2,MNAME2,
            year3,reason_short3,ID3,reason3,MNAME3,
            year4,reason_short4,ID4,reason4,MNAME4,
         everything())

df_change2 <- df_change %>% filter(!is.na(year1))
df_change2 %>% write_csv(file=here('data','output','df_change2.csv'))
df_change3 <- read_csv(here('data','output','df_change2.csv'))

# row 826 of df_change3 : negative number,
# merger result / dissolved into: has multiple numbers
#                                 -> now capturing only the first