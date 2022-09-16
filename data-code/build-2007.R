rm(list=ls())
library(tidyverse)
## load
y <- 2007
df_hosp <- read.csv(paste0("data/input/AHA FY 2007/COMMA/comma.csv"))
df_hosp <- df_hosp %>% select('ID') %>% mutate(year=y)
df_reg_add <- read.csv(paste0("data/temp/change_reg_add_",y,".csv"))
df_reg_del <- read.csv(paste0("data/temp/change_reg_del_",y,".csv"))
df_nonreg_add <- read.csv(paste0("data/temp/change_nonreg_add_",y,".csv"))
df_nonreg_del <- read.csv(paste0("data/temp/change_nonreg_del_",y,".csv"))

## functions
spl <- function(text) {
  li <- str_split(text, " ")
  return(li[[1]])
}
spl_first <- function(text) spl(text)[1]
spl_last <- function(text) tail(spl(text),n=1)

## clean
# main data

# reg add
dfnames = c("df_reg_add", "df_nonreg_add")
for (i in 1:length(dfnames)) {
  df <- eval(parse(text=dfnames[i]))
  df$reason_head <- lapply(df$REASON.FOR.ADDITION, spl_first)
  df <- df %>%
    mutate(ID = as.character(ID),
           add=1, register=1,
           demerged = ifelse(reason_head=='Demerged',1,0),
           reopen = ifelse(reason_head=='Reopened',1,0),
           new = ifelse(reason_head=='Newly',1,0))
  # if demerged, from where
  df_temp <- df %>% filter(demerged == 1) %>%
    select(ID, REASON.FOR.ADDITION)
  df_temp$demerged_from = lapply(df_temp$REASON.FOR.ADDITION, spl_last)
  df_reg_add <- df %>% 
    left_join(df_temp, by='ID',suffix=c("","x")) %>%
    select(-c(REASON.FOR.ADDITIONx))
  assign(paste0("df_tmp",i),df)
}
df_adds = bind_rows(df_tmp1, df_tmp2)
df_hosp <- df_hosp %>% left_join(df_adds, by='ID')
# df_reg_add$reason_head <- lapply(df_reg_add$REASON.FOR.ADDITION, spl_first)
# df_reg_add <- df_reg_add %>%
#   mutate(ID = as.character(ID),
#          year=y, add=1, register=1,
#          demerged = ifelse(reason_head=='Demerged',1,0),
#          reopen = ifelse(reason_head=='Reopened',1,0),
#          new = ifelse(reason_head=='Newly',1,0))
# df_temp <- df_reg_add %>% filter(demerged == 1) %>%
#   select(ID, REASON.FOR.ADDITION)
# df_temp$demerged_from = lapply(df_temp$REASON.FOR.ADDITION, spl_last)
# df_reg_add <- df_reg_add %>%
#   left_join(df_temp, by='ID',suffix=c("","x")) %>%
#   select(-c(REASON.FOR.ADDITIONx))

# nonreg add
df_nonreg_add$reason_head <- lapply(df_nonreg_add$REASON.FOR.ADDITION, spl_first)
df_nonreg_add <- df_nonreg_add %>% 
  mutate(ID = as.character(ID),
         year=y,add=1,register=0,
         demerged = ifelse(reason_head=='Demerged',1,0),
         reopen = ifelse(reason_head=='Reopened',1,0),
         new = ifelse(reason_head=='Newly',1,0))
df_temp <- df_nonreg_add %>% filter(demerged == 1) %>%
  select(ID, REASON.FOR.ADDITION)
df_temp$demerged_from = lapply(df_temp$REASON.FOR.ADDITION, spl_last)
df_nonreg_add <- df_nonreg_add %>% 
  left_join(df_temp, by='ID',suffix=c("","x")) %>%
  select(-c(REASON.FOR.ADDITIONx))
  
df_adds <- bind_rows(df_reg_add, df_nonreg_add)

df_hosp <- df_hosp %>% left_join(df_adds, by='ID')

# reg del
df_reg_del$reason_head = lapply(df_reg_del$REASON.FOR.DELETION, spl_first)
df_reg_del <- df_reg_del %>% 
  mutate(ID = as.character(ID),
         year = 1, del =1, registered = 1,
         merged = ifelse(reason_head=="Merged",1,0),
         closed = ifelse(reason_head=="Closed",1,0))
df_temp <- df_reg_del %>% 
  filter(merged == 1) %>%
  select(ID, REASON.FOR.DELETION)
df_temp$merged_into = lapply(df_temp$REASON.FOR.DELETION, spl_last)
df_reg_del <- df_reg_del %>% left_join(df_temp, by="ID", suffix=c("","x"))
# not hosptial/outpatient

# nonreg del
df_nonreg_del$reason_head = lapply(df_nonreg_del$REASON.FOR.DELETION, spl_first)
df_nonreg_del <- df_nonreg_del %>% 
  mutate(ID = as.character((ID)),
         merged = ifelse(reason_head=="Merged",1,0),
         year = 1, del =1, registered = 0,
         closed = ifelse(reason_head=="Closed",1,0))
df_temp <- df_nonreg_del %>% 
  filter(merged == 1) %>%
  select(ID, REASON.FOR.DELETION)
df_temp$merged_into = lapply(df_temp$REASON.FOR.DELETION, spl_last)
df_nonreg_del <- df_nonreg_del %>% left_join(df_temp, by="ID", suffix=c("","x"))

df_dels <- bind_rows(df_reg_del, df_nonreg_add)