# Meta ---------------------------------------------------------
# Author: Wonjun Choi
# Date: Sept-29-2022
# Description: A file to add a reason of change in 2007
#
# load change data ------------------------------------------------
y <- 2017
df_year <- df_hosp %>% filter(year==y)
df_reg_add <- read.csv(paste0("data/temp/change_Reg Add_",y,".csv"))
df_reg_del <- read.csv(paste0("data/temp/change_Reg Del_",y,".csv"))
df_nonreg_add <- read.csv(paste0("data/temp/change_Nonreg Add_",y,".csv"))
df_nonreg_del <- read.csv(paste0("data/temp/change_Nonreg Del_",y,".csv"))

# functions ------------------------------------------------------
spl <- function(text) {
  li <- str_split(text, " ")
  return(li[[1]])
}
spl_first <- function(text) unlist(spl(text))[1]
spl_last <- function(text) tail(unlist(spl(text)),n=1)

# addition ----------------------------------------------------------
df_add <- rbind(df_reg_add, df_nonreg_add)  # reg status doesn't matter
df_add <- df_add %>%
  mutate(ID = as.character(ID), add=1,
         reason = REASON.FOR.ADDITION)
df_add$reason_head <- lapply(df_add$reason, spl_first)

df_add <- df_add %>%  # create dummies for reason_head
  filter(reason_head != 'Status',
         reason_head != 'status') %>%
  mutate(dummy=1, readum = reason_head) %>% 
  spread(readum, value=dummy, sep='_')

df_add <- df_add %>%  # update to df_hosp
  select(ID, add, reason, reason_head, starts_with('readum_')) %>%
  mutate(year = y)
df_year <- df_year %>%
  left_join(df_add, by=c('ID','year'))

# deletion ------------------------------------------------------
df_del <- rbind(df_reg_del, df_nonreg_del)
df_del$reason_head <- lapply(df_del$REASON.FOR.DELETION, spl_first)
df_del <- df_del %>%
  mutate(ID = as.character(ID),
         del = 1, 
         reason = REASON.FOR.DELETION,
         year = y)

df_del <- df_del %>%  # create dummies for reason_head
  filter(reason_head != 'Status') %>%
  mutate(dummy=1,
         readum = reason_head) %>% 
  spread(readum, value=dummy, sep='_')  

df_del <- df_del %>%  # update to df_hosp
  select(ID, del, reason, reason_head, starts_with('readum_')) %>%
  mutate(year = y)

df_year <- bind_rows(df_year, df_del)