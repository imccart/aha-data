# Meta --------------------------------------------------------------------
## Title:         AHA Data
## Author:        Ian McCarthy
## Date Created:  2/5/2018
## Date Edited:   7/14/2023


# Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, tidyverse, janitor, here)


# Import yearly AHA data --------------------------------------------------

aha.final <- tibble()
for (y in 2007:2019){
  if (y == 2007) {
    aha.path <- here('data/input/AHA Data',paste0('AHA FY ',y),'COMMA','comma.csv')
  } else if (y==2008) {
    aha.path <- here('data/input/AHA Data',paste0('AHA FY ',y),'COMMA','pubas08.csv')
  } else if (y==2009) {
    aha.path <- here('data/input/AHA Data',paste0('AHA FY ',y),'Comma','pubas09.csv')
  } else if (y<=2012) {
    aha.path <- here('data/input/AHA Data',paste0('AHA FY ',y),
              'COMMA', paste0('ASPUB',y-2000,'.csv'))
  } else if (y>2012 & y<=2015) {
    aha.path <- here('data/input/AHA Data',paste0('AHA FY ',y),
              'COMMA', paste0('ASPUB',y-2000,'.CSV'))
  } else {
    aha.path <- here('data/input/AHA Data',paste0('AHA FY ',y),
              paste0('ASPUB',y-2000,'.csv'))
  }
  aha.data <- read_csv(aha.path) %>%
    select(any_of(c('ID', 'SYSID', 'MCRNUM', 'NPINUM', 'MNAME', 'MTYPE', 'MLOS', 'DTBEG', 'DTEND', 'FISYR',
                    'LAT', 'LONG', 'MLOCCITY','MLOCZIP', 'MSTATE', 'FSTCD', 'FCNTYCD', 
                    'HRRNAME', 'HRRCODE', 'HSANAME', 'HSACODE', 
                    'BDTOT', 'COMMTY', 'SYSTELN', 'EHLTH', 'CNTRL', 
                    'MAPP1','MAPP2','MAPP3','MAPP4','MAPP5','MAPP6','MAPP7','MAPP8','MAPP9','MAPP10',
                    'MAPP11','MAPP12','MAPP13','MAPP14','MAPP15','MAPP16','MAPP17','MAPP18',
                    'MHSMEMB', 'FTEMD', 'FTERES', 
                    'FTERN', 'FTELPN', 'FTEH', 'NAMMSHOS', 'ACLABHOS', 'ENDOCHOS', 'ENDOUHOUS',
                    'REDSHOS', 'CTSCNHOS', 'DRADFHOS', 'EBCTHOS', 'FFDMHOS', 'MRIHOS', 'IMRIHOS',
                    'MSCTHOS', 'MSCTGHOS', 'PETHOS', 'PETCTHOS', 'SPECTHOS', 'ULTSNHOS',
                    'AMBSHOS', 'EMDEPHOS', 'ICLABHOS', 'ADTCHOS', 'ADTEHOS', 'CHTHHOS', 'CAOSHOS',
                    'ONCOLHO', 'RASTHOS', 'IMRTHOS', 'PTONHOS', 'CICBD', 'NICBD', 'NINTBD', 'PEDICBD',
                    'BROOMHOS', 'ACLABHOS', 'CARIC', 'CTSCNHOS', 'DRADFHOS', 'ESWLHOS', 'FITCHOS',
                    'ADTCHOS', 'PETHOS', 'IGRTHOS', 'IMRTHOS', 'SPECTHOS', 'SPORTHOS', 'ULTSNHOS', 
                    'WOMHCHOS', 'ALCHBD', 'BRNBD', 'PSYBD', 'TRAUMHOS', 'PSYCAHOS', 'EMDEPHOS', 
                    'AIDSSHOS', 'PSYSLSHOS', 'PSYEDHOS', 'PSYEMHOS', 'PSYOPHOS', 'PSYPHHOS', 
                    'ADULTHOS', 'HOSPCHOS', 'PATEDHOS', 'SOCWKHOS', 'VOLSVHOS', 'GPWWHOS', 'OPHHOS', 
                    'CPHHOS', 'FNDHOS', 'EQMHOS', 'IPAHOS', 'MSOHOS', 'ISMHOS', 'GPWWNET', 'OPHNET', 
                    'CPHNET', 'FNDNET', 'EQMNET', 'IPANET', 'MSONET', 'ISMNET', 'GPWWSYS', 'OPHSYS', 
                    'CPHSYS', 'FNDSYS', 'EQMSYS', 'IPASYS', 'MSOSYS', 'ISMSYS', 'PHYGP',
                    'CAH','RRCTR','SCPROV'))) %>%
    mutate(year=y) %>%
    mutate(across(any_of(c('EHLTH','ACLABHOS','CTSCNHOS','DRADFHOS','EBCTHOS',
                    'FFDMHOS','MRIHOS','IMRIHOS','MSCTHOS','MSCTGHOS',
                    'PETHOS','PETCTHOS','SPECTHOS','ULTSNHOS','AMBSHOS',
                    'EMDEPHOS','ICLABHOS','ADTCHOS','CHTHHOS','CAOSHOS',
                    'IMRTHOS','PTONHOS','BROOMHOS','ESWLHOS','FITCHOS',
                    'IGRTHOS','SPORTHOS','WOMHCHOS','TRAUMHOS','PSYCAHOS',
                    'AIDSSHOS','PSYEDHOS','PSYEMHOS','PSYOPHOS','PSYPHHOS',
                    'ADULTHOS','HOSPCHOS','PATEDHOS','SOCWKHOS','VOLSVHOS',
                    'GPWWHOS','IPAHOS','MSOHOS','ISMHOS','GPWWNET','IPANET',
                    'MSONET','ISMNET','GPWWSYS','IPASYS','MSOSYS','ISMSYS',
                    'ID','NPINUM','HRRCODE','SYSID','FSTCD','FCNTYCD',
                    'CAH','RRCTR','SCPROV')), ~ as_factor(.)),
           across(any_of(c('LAT','LONG','SYSTELN','CICBD','NICBD', 'HSACODE',
                           'NINTBD','PEDICBD','ALCHBD','BRNBD','PSYBD')), ~ as.numeric(.)),
           across(any_of(c('DTBEG','DTEND','FISYR','MSTATE')), ~as.character(.)))
  
  aha.final <- bind_rows(aha.final, aha.data)
  
}


# Tidy AHA data -----------------------------------------------------------

aha.final <- aha.final %>%
  mutate(
    critical_access = case_when(
      year<2009 & CAH==2 ~ 0,
      year<2009 & CAH==1 ~ 1,
      year>=2009 & MAPP18==2 ~ 0,
      year>=2009 & MAPP18==1 ~ 1,
      TRUE ~ 0),
    own_type = between(CNTRL, 12, 16) +
           2*between(CNTRL, 21, 23) +
           3*between(CNTRL, 30, 33) +
           4*between(CNTRL, 41, 48),
    own_gov=ifelse(own_type==1, 1, 0),
    own_nfp=ifelse(own_type==2, 1, 0),
    own_profit=ifelse(own_type==3, 1, 0),
    teach_major=ifelse(MAPP8==1, 1, 0),
    teach_minor=ifelse(MAPP3==1 | MAPP5==1 | MAPP8==1 | MAPP12==1 | MAPP13==1, 1, 0),
    system=ifelse(!is.na(SYSID) | MHSMEMB==1, 1, 0)) %>%
  filter(!is.na(ID)) %>%
  select(-c(CAH,MAPP18))

## check for duplicates
aha.duplicates <- aha.final %>%
  group_by(ID, year) %>%
  filter(n()>1) %>%
  ungroup()

# Merge summary of changes information ------------------------------------

changes.data <- read_csv('data/output/df_change.csv') %>%
  mutate(ID5=NA)
  

any.change <- changes.data %>%
  distinct(ID)

## reshape to long
dat.list <- list()
for (i in 1:5) {
  y_col <- paste0("year",i)
  rs_col <- paste0("reason_short",i)
  r_col <- paste0("reason",i)
  id_col <- paste0("ID",i)
  dat.list[[i]] <- list(y_col=y_col, rs_col=rs_col, r_col=r_col, id_col=id_col)
}

changes.y <- map(dat.list, ~ {
  changes.data %>%
    select(ID, year=.x$y_col, reason_short=.x$rs_col, reason=.x$r_col, other_ID=.x$id_col)}) %>% 
  bind_rows() %>%
  filter(!is.na(year)) 

## break into different reasons for changes
aha.closures <- changes.y %>%
  filter(reason_short %in% c("closed","temporarily closed","dissolution")) %>%
  select(-other_ID, -reason_short) %>%
  mutate(change_type="Closure",
         year=year-1)

aha.merger <- changes.y %>%
  filter(reason_short %in% c("demerger","demerged","merged into", "merger result")) %>%
  select(-reason_short) %>%
  mutate(change_type="Merger") %>%
  group_by(ID, year) %>%
  filter(row_number()==1) %>%
  ungroup() %>%
  mutate(year=year-1)

aha.rename <- changes.y %>%
  filter(reason_short %in% c("ID change","formerly sth else")) %>%
  select(-reason_short) %>%
  mutate(change_type="Name Change",
         year=year-1)

aha.new <- changes.y %>%
  filter(reason_short %in% c("newly added","reopened")) %>%
  select(-other_ID, -reason_short) %>%
  mutate(change_type="New")

aha.other.change <- changes.y %>%
  filter(reason_short %in% c("duplicate","idk","not a hosp","unit of other hosp")) %>%
  select(-reason_short) %>%
  mutate(change_type="Other",
         year=year-1)

aha.all.changes <- bind_rows(aha.closures, aha.merger, aha.rename, aha.other.change) %>%
  arrange(ID, year) %>%
  group_by(ID) %>%
  mutate(change_count=row_number()) %>%
  ungroup() %>%
  mutate(change_source1="Summary of Changes") %>%
  rename(change_reason=reason)

## identify ID changes in AHA surveys
aha.id.years <- aha.final %>% select(ID, year) %>%
  group_by(ID) %>%
  mutate(first_year=min(year), last_year=max(year)) %>%
  ungroup() %>%
  select(ID, first_year, last_year)

aha.survey.changes <- aha.id.years %>%
  filter(last_year<2019) %>%
  select(ID, year=last_year) %>%
  group_by(ID, year) %>%
  filter(row_number()==1) %>%
  ungroup() %>%
  mutate(change_source2="AHA Survey IDs")



# Merge and save final data -----------------------------------------------

aha.combine <- aha.final %>%
  left_join(aha.all.changes,
            by=c("ID","year")) %>%
  left_join(aha.survey.changes, 
            by=c("ID","year")) %>%
  mutate(change_source=
           case_when(
             !is.na(change_source1) & is.na(change_source2) ~ "Summary of Changes",
             is.na(change_source1) & !is.na(change_source2) ~ "AHA Survey ID",
             !is.na(change_source1) & !is.na(change_source2) ~ "Both",
             is.na(change_source1) & is.na(change_source2) ~ "No Change")
           ) %>%
  select(-change_source1, -change_source2) %>%
  write_csv('data/output/aha_data.csv')



  