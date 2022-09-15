rm(list=ls())

y <- 2007
df_reg_add <- read.csv(paste0("data/temp/change_reg_add_",y,".csv"))
df_reg_del <- read.csv(paste0("data/temp/change_reg_del_",y,".csv"))
df_nonreg_add <- read.csv(paste0("data/temp/change_nonreg_add_",y,".csv"))
df_nonreg_del <- read.csv(paste0("data/temp/change_nonreg_del_",y,".csv"))

df <- tibble()