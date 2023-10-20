# Meta --------------------------------------------------------------------
## Title:         AHA Data
## Author:        Ian McCarthy
## Date Created:  2/5/2018
## Date Edited:   10/4/2023


# Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, tidyverse, janitor, here, readstata13)


# Import historic AHA data ------------------------------------------------

aha.historic <- tibble()
for (y in 1980:2006) {
  aha.data <- read.dta13(paste0('data/input/AHA Data/NBER AHA Data (from C. DePasquale)/aha_extract',y,'.dta')) %>%
    mutate(year=y) %>%
    mutate(across(any_of(c('mngt','radmchi','msic82','mcounty','ppo','mhsmemb','subs','sysid',
                           'fcounty','fstcd','fcntycd','netstcd','mngtstcd',
                           'reg','stcd','chc','los','serv')), ~ as_factor(.)),
           across(any_of(c('genbd','pedbd','obbd','msicbd','cicbd','pedicbd','nicbd','nintbd',
                           'brnbd','othicbd','rehabbd','othbd','othbdtot','hospbd',
                           'bdh','admh','ipdh','npaybenh','spcicbd','mcrdch',
                           'mcripdh','mcddch','mcdipdh','mcrdclt','mcripdlt',
                           'mcddclt','mcdipdlt','npayben','hsacode','lat','lon')), ~ as.numeric(.)),
           across(any_of(c('dtbeg','dtend','fyr','dbegd','dbegy','dendm','dbegm','dendd',
                           'dendy')), ~as.character(.)))
      
  aha.historic <- bind_rows(aha.historic, aha.data)
}

## for now...
## only pull critical variables on hospital location/ID, ownership type, bed size, type, and FTEs
## consider pulling info on specific services, bed types, and physician arrangements
aha.historic <- aha.historic %>%
  select(id, sysid, hospno, mcrnum, mtype, mlos=los, dtbeg, dtend, fisyr=fyr,
         lat, long=lon, mstate, fstcd, fcntycd,
         bdtot, commty=chc, cntrl, serv,
         starts_with('mapp'),
         hsaname, hsacode,
         mhsmemb, ftemd, ftern, ftelpn, year) %>%
  rename_with(toupper) %>%
  rename(year=YEAR)




# Import WRDS AHA data ----------------------------------------------------

aha.data.1994 <- read_csv('data/input/AHA Data/AHA FY 1994-2021/ANNUAL_SURVEY_HIST_1994_RECENT.csv') %>%
  select(any_of(c('ID', 'SYSID', 'MCRNUM', 'NPINUM', 'MNAME', 'MTYPE', 'MLOS', 'DTBEG', 'DTEND', 'FISYR',
                    'LAT', 'LONG', 'MLOCCITY','MLOCZIP', 'MSTATE', 'MLOCAD1', 'MLOCAD2', 'FSTCD', 'FCNTYCD', 
                    'HRRNAME', 'HRRCODE', 'HSANAME', 'HSACODE', 
                    'BDTOT', 'COMMTY'='CHC', 'EHLTH', 'CNTRL', 'SERV',
                    'MAPP1','MAPP2','MAPP3','MAPP4','MAPP5','MAPP6','MAPP7','MAPP8','MAPP9','MAPP10',
                    'MAPP11','MAPP12','MAPP13','MAPP14','MAPP15','MAPP16','MAPP17','MAPP18',
                    'MHSMEMB', 'FTEMD', 'FTERES', 'ADMTOT', 'IPDTOT', 'MCDDC', 'MCRDC',
                    'FTERN', 'FTELPN', 'FTEH', 'NAMMSHOS', 'ACLABHOS', 'ENDOCHOS', 'ENDOUHOUS',
                    'REDSHOS', 'CTSCNHOS', 'DRADFHOS', 'EBCTHOS', 'FFDMHOS', 'MRIHOS', 'IMRIHOS',
                    'MSCTHOS', 'MSCTGHOS', 'PETHOS', 'PETCTHOS', 'SPECTHOS', 'ULTSNHOS',
                    'AMBSHOS', 'EMDEPHOS', 'ICLABHOS', 'ADTCHOS', 'ADTEHOS', 'CHTHHOS', 'CAOSHOS',
                    'ONCOLHO', 'RASTHOS', 'IMRTHOS', 'CICBD', 'NICBD', 'NINTBD', 'PEDICBD',
                    'BROOMHOS', 'ACLABHOS', 'CARIC', 'CTSCNHOS', 'DRADFHOS', 'ESWLHOS', 'FITCHOS',
                    'ADTCHOS', 'PETHOS', 'IGRTHOS', 'IMRTHOS', 'SPECTHOS', 'SPORTHOS', 'ULTSNHOS', 
                    'WOMHCHOS', 'ALCHBD', 'BRNBD', 'PSYBD', 'TRAUMHOS', 'PSYCAHOS', 'EMDEPHOS', 
                    'AIDSSHOS', 'PSYSLSHOS', 'PSYEDHOS', 'PSYEMHOS', 'PSYOPHOS', 'PSYPHHOS', 
                    'ROBOHOS', 'ROBOSYS', 'ROBONET', 'ROBOVEN', 'PTONHOS', 'PTONSYS', 'PTONNET', 'PTONVEN',
                    'SRADHOS', 'SRADSYS', 'SRADNET', 'SRADVEN',
                    'ADULTHOS', 'HOSPCHOS', 'PATEDHOS', 'SOCWKHOS', 'VOLSVHOS', 'GPWWHOS', 'OPHHOS', 
                    'CPHHOS', 'FNDHOS', 'EQMHOS', 'IPAHOS', 'MSOHOS', 'ISMHOS', 'GPWWNET', 'OPHNET', 
                    'CPHNET', 'FNDNET', 'EQMNET', 'IPANET', 'MSONET', 'ISMNET', 'GPWWSYS', 'OPHSYS', 
                    'CPHSYS', 'FNDSYS', 'EQMSYS', 'IPASYS', 'MSOSYS', 'ISMSYS', 'PHYGP',
                    'CAH','RRCTR','SCPROV', 'YEAR'))) %>%
    mutate(across(any_of(c('EHLTH','ACLABHOS','CTSCNHOS','DRADFHOS','EBCTHOS',
                    'FFDMHOS','MRIHOS','IMRIHOS','MSCTHOS','MSCTGHOS',
                    'PETHOS','PETCTHOS','SPECTHOS','ULTSNHOS','AMBSHOS',
                    'EMDEPHOS','ICLABHOS','ADTCHOS','CHTHHOS','CAOSHOS',
                    'IMRTHOS', 'BROOMHOS','ESWLHOS','FITCHOS',
                    'IGRTHOS','SPORTHOS','WOMHCHOS','TRAUMHOS','PSYCAHOS',
                    'AIDSSHOS','PSYEDHOS','PSYEMHOS','PSYOPHOS','PSYPHHOS',
                    'ADULTHOS','HOSPCHOS','PATEDHOS','SOCWKHOS','VOLSVHOS',
                    'GPWWHOS','IPAHOS','MSOHOS','ISMHOS','GPWWNET','IPANET',
                    'MSONET','ISMNET','GPWWSYS','IPASYS','MSOSYS','ISMSYS',
                    'ID','NPINUM','HRRCODE','SYSID','FSTCD','FCNTYCD',
                    'CAH','RRCTR','SCPROV','SERV','COMMTY','MLOS','MHSMEMB',
                    'ROBOHOS', 'ROBOSYS', 'ROBONET', 'ROBOVEN', 'PTONHOS', 'PTONSYS', 'PTONNET', 'PTONVEN',
                    'SRADHOS', 'SRADSYS', 'SRADNET', 'SRADVEN')), ~ as_factor(.)),
           across(any_of(c('LAT','LONG','SYSTELN','CICBD','NICBD', 'HSACODE',
                           'NINTBD','PEDICBD','ALCHBD','BRNBD','PSYBD')), ~ as.numeric(.)),
           across(any_of(c('DTBEG','DTEND','FISYR','MSTATE')), ~as.character(.)))  %>% 
    filter(YEAR<2007) %>%
    rename(year=YEAR) %>%
    mutate(COMMTY=case_when(
      COMMTY==2 ~ "N",
      COMMTY==1 ~ "Y",
      TRUE ~ NA_character_))

aha.data.1986 <- read_csv('data/input/AHA Data/AHA FY 1986-1993/ANNUAL_SURVEY_HIST_1986_1993.csv') %>% 
    select(any_of(c('ID', 'SYSID', 'MCRNUM', 'NPINUM', 'MNAME', 'MTYPE', 'MLOS', 'DTBEG', 'DTEND', 'FISYR',
                    'LAT', 'LONG', 'MLOCCITY','MLOCZIP', 'MSTATE', 'MLOCAD1', 'MLOCAD2', 'FSTCD', 'FCNTYCD', 
                    'HRRNAME', 'HRRCODE', 'HSANAME', 'HSACODE', 
                    'BDTOT', 'COMMTY'='CHC', 'EHLTH', 'CNTRL', 'SERV',
                    'MAPP1','MAPP2','MAPP3','MAPP4','MAPP5','MAPP6','MAPP7','MAPP8','MAPP9','MAPP10',
                    'MAPP11','MAPP12','MAPP13','MAPP14','MAPP15','MAPP16','MAPP17','MAPP18',
                    'MHSMEMB', 'FTEMD', 'FTERES', 'ADMTOT', 'IPDTOT', 'MCDDC', 'MCRDC',
                    'FTERN', 'FTELPN', 'FTEH', 'NAMMSHOS', 'ACLABHOS', 'ENDOCHOS', 'ENDOUHOUS',
                    'REDSHOS', 'CTSCNHOS', 'DRADFHOS', 'EBCTHOS', 'FFDMHOS', 'MRIHOS', 'IMRIHOS',
                    'MSCTHOS', 'MSCTGHOS', 'PETHOS', 'PETCTHOS', 'SPECTHOS', 'ULTSNHOS',
                    'AMBSHOS', 'EMDEPHOS', 'ICLABHOS', 'ADTCHOS', 'ADTEHOS', 'CHTHHOS', 'CAOSHOS',
                    'ONCOLHO', 'RASTHOS', 'IMRTHOS', 'CICBD', 'NICBD', 'NINTBD', 'PEDICBD',
                    'BROOMHOS', 'ACLABHOS', 'CARIC', 'CTSCNHOS', 'DRADFHOS', 'ESWLHOS', 'FITCHOS',
                    'ADTCHOS', 'PETHOS', 'IGRTHOS', 'IMRTHOS', 'SPECTHOS', 'SPORTHOS', 'ULTSNHOS', 
                    'WOMHCHOS', 'ALCHBD', 'BRNBD', 'PSYBD', 'TRAUMHOS', 'PSYCAHOS', 'EMDEPHOS', 
                    'AIDSSHOS', 'PSYSLSHOS', 'PSYEDHOS', 'PSYEMHOS', 'PSYOPHOS', 'PSYPHHOS', 
                    'ROBOHOS', 'ROBOSYS', 'ROBONET', 'ROBOVEN', 'PTONHOS', 'PTONSYS', 'PTONNET', 'PTONVEN',
                    'SRADHOS', 'SRADSYS', 'SRADNET', 'SRADVEN',
                    'ADULTHOS', 'HOSPCHOS', 'PATEDHOS', 'SOCWKHOS', 'VOLSVHOS', 'GPWWHOS', 'OPHHOS', 
                    'CPHHOS', 'FNDHOS', 'EQMHOS', 'IPAHOS', 'MSOHOS', 'ISMHOS', 'GPWWNET', 'OPHNET', 
                    'CPHNET', 'FNDNET', 'EQMNET', 'IPANET', 'MSONET', 'ISMNET', 'GPWWSYS', 'OPHSYS', 
                    'CPHSYS', 'FNDSYS', 'EQMSYS', 'IPASYS', 'MSOSYS', 'ISMSYS', 'PHYGP',
                    'CAH','RRCTR','SCPROV', 'year'))) %>%
    mutate(across(any_of(c('EHLTH','ACLABHOS','CTSCNHOS','DRADFHOS','EBCTHOS',
                    'FFDMHOS','MRIHOS','IMRIHOS','MSCTHOS','MSCTGHOS',
                    'PETHOS','PETCTHOS','SPECTHOS','ULTSNHOS','AMBSHOS',
                    'EMDEPHOS','ICLABHOS','ADTCHOS','CHTHHOS','CAOSHOS',
                    'IMRTHOS','BROOMHOS','ESWLHOS','FITCHOS',
                    'IGRTHOS','SPORTHOS','WOMHCHOS','TRAUMHOS','PSYCAHOS',
                    'AIDSSHOS','PSYEDHOS','PSYEMHOS','PSYOPHOS','PSYPHHOS',
                    'ADULTHOS','HOSPCHOS','PATEDHOS','SOCWKHOS','VOLSVHOS',
                    'GPWWHOS','IPAHOS','MSOHOS','ISMHOS','GPWWNET','IPANET',
                    'MSONET','ISMNET','GPWWSYS','IPASYS','MSOSYS','ISMSYS',
                    'ID','NPINUM','HRRCODE','SYSID','FSTCD','FCNTYCD',
                    'CAH','RRCTR','SCPROV','SERV','COMMTY','MLOS','MHSMEMB',
                    'ROBOHOS', 'ROBOSYS', 'ROBONET', 'ROBOVEN', 'PTONHOS', 'PTONSYS', 'PTONNET', 'PTONVEN',
                    'SRADHOS', 'SRADSYS', 'SRADNET', 'SRADVEN')), ~ as_factor(.)),
           across(any_of(c('LAT','LONG','SYSTELN','CICBD','NICBD', 'HSACODE',
                           'NINTBD','PEDICBD','ALCHBD','BRNBD','PSYBD')), ~ as.numeric(.)),
           across(any_of(c('DTBEG','DTEND','FISYR','MSTATE')), ~as.character(.))) %>%
    mutate(COMMTY=case_when(
      COMMTY==2 ~ "N",
      COMMTY==1 ~ "Y",
      TRUE ~ NA_character_))


aha.data.1980 <- read_csv('data/input/AHA Data/AHA FY 1980-1985/ANNUAL_SURVEY_HIST_1980_1985.csv') %>% 
    select(any_of(c('ID', 'SYSID', 'MCRNUM', 'NPINUM', 'MNAME', 'MTYPE', 'MLOS', 'DTBEG', 'DTEND', 'FISYR',
                    'LAT', 'LONG', 'MLOCCITY','MLOCZIP', 'MSTATE', 'MLOCAD1', 'MLOCAD2', 'FSTCD', 'FCNTYCD', 
                    'HRRNAME', 'HRRCODE', 'HSANAME', 'HSACODE', 
                    'BDTOT', 'COMMTY'='CHC', 'EHLTH', 'CNTRL', 'SERV',
                    'MAPP1','MAPP2','MAPP3','MAPP4','MAPP5','MAPP6','MAPP7','MAPP8','MAPP9','MAPP10',
                    'MAPP11','MAPP12','MAPP13','MAPP14','MAPP15','MAPP16','MAPP17','MAPP18',
                    'MHSMEMB', 'FTEMD', 'FTERES', 'ADMTOT', 'IPDTOT', 'MCDDC', 'MCRDC',
                    'FTERN', 'FTELPN', 'FTEH', 'NAMMSHOS', 'ACLABHOS', 'ENDOCHOS', 'ENDOUHOUS',
                    'REDSHOS', 'CTSCNHOS', 'DRADFHOS', 'EBCTHOS', 'FFDMHOS', 'MRIHOS', 'IMRIHOS',
                    'MSCTHOS', 'MSCTGHOS', 'PETHOS', 'PETCTHOS', 'SPECTHOS', 'ULTSNHOS',
                    'AMBSHOS', 'EMDEPHOS', 'ICLABHOS', 'ADTCHOS', 'ADTEHOS', 'CHTHHOS', 'CAOSHOS',
                    'ONCOLHO', 'RASTHOS', 'IMRTHOS', 'CICBD', 'NICBD', 'NINTBD', 'PEDICBD',
                    'BROOMHOS', 'ACLABHOS', 'CARIC', 'CTSCNHOS', 'DRADFHOS', 'ESWLHOS', 'FITCHOS',
                    'ADTCHOS', 'PETHOS', 'IGRTHOS', 'IMRTHOS', 'SPECTHOS', 'SPORTHOS', 'ULTSNHOS', 
                    'WOMHCHOS', 'ALCHBD', 'BRNBD', 'PSYBD', 'TRAUMHOS', 'PSYCAHOS', 'EMDEPHOS', 
                    'AIDSSHOS', 'PSYSLSHOS', 'PSYEDHOS', 'PSYEMHOS', 'PSYOPHOS', 'PSYPHHOS', 
                    'ROBOHOS', 'ROBOSYS', 'ROBONET', 'ROBOVEN', 'PTONHOS', 'PTONSYS', 'PTONNET', 'PTONVEN',
                    'SRADHOS', 'SRADSYS', 'SRADNET', 'SRADVEN',                    
                    'ADULTHOS', 'HOSPCHOS', 'PATEDHOS', 'SOCWKHOS', 'VOLSVHOS', 'GPWWHOS', 'OPHHOS', 
                    'CPHHOS', 'FNDHOS', 'EQMHOS', 'IPAHOS', 'MSOHOS', 'ISMHOS', 'GPWWNET', 'OPHNET', 
                    'CPHNET', 'FNDNET', 'EQMNET', 'IPANET', 'MSONET', 'ISMNET', 'GPWWSYS', 'OPHSYS', 
                    'CPHSYS', 'FNDSYS', 'EQMSYS', 'IPASYS', 'MSOSYS', 'ISMSYS', 'PHYGP',
                    'CAH','RRCTR','SCPROV', 'year'))) %>%
    mutate(across(any_of(c('EHLTH','ACLABHOS','CTSCNHOS','DRADFHOS','EBCTHOS',
                    'FFDMHOS','MRIHOS','IMRIHOS','MSCTHOS','MSCTGHOS',
                    'PETHOS','PETCTHOS','SPECTHOS','ULTSNHOS','AMBSHOS',
                    'EMDEPHOS','ICLABHOS','ADTCHOS','CHTHHOS','CAOSHOS',
                    'IMRTHOS','BROOMHOS','ESWLHOS','FITCHOS',
                    'IGRTHOS','SPORTHOS','WOMHCHOS','TRAUMHOS','PSYCAHOS',
                    'AIDSSHOS','PSYEDHOS','PSYEMHOS','PSYOPHOS','PSYPHHOS',
                    'ADULTHOS','HOSPCHOS','PATEDHOS','SOCWKHOS','VOLSVHOS',
                    'GPWWHOS','IPAHOS','MSOHOS','ISMHOS','GPWWNET','IPANET',
                    'MSONET','ISMNET','GPWWSYS','IPASYS','MSOSYS','ISMSYS',
                    'ID','NPINUM','HRRCODE','SYSID','FSTCD','FCNTYCD',
                    'CAH','RRCTR','SCPROV','SERV','COMMTY','MLOS','MHSMEMB',
                    'ROBOHOS', 'ROBOSYS', 'ROBONET', 'ROBOVEN', 'PTONHOS', 'PTONSYS', 'PTONNET', 'PTONVEN',
                    'SRADHOS', 'SRADSYS', 'SRADNET', 'SRADVEN')), ~ as_factor(.)),
           across(any_of(c('LAT','LONG','SYSTELN','CICBD','NICBD', 'HSACODE',
                           'NINTBD','PEDICBD','ALCHBD','BRNBD','PSYBD')), ~ as.numeric(.)),
           across(any_of(c('DTBEG','DTEND','FISYR','MSTATE')), ~as.character(.))) %>%
      mutate(COMMTY=case_when(
        COMMTY==2 ~ "N",
        COMMTY==1 ~ "Y",
        TRUE ~ NA_character_))


aha.historic <- bind_rows(aha.data.1980, aha.data.1986, aha.data.1994)

# Import yearly AHA data --------------------------------------------------

aha.modern <- tibble()
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
                    'BDTOT', 'COMMTY'='CHC', 'EHLTH', 'CNTRL', 'SERV',
                    'MAPP1','MAPP2','MAPP3','MAPP4','MAPP5','MAPP6','MAPP7','MAPP8','MAPP9','MAPP10',
                    'MAPP11','MAPP12','MAPP13','MAPP14','MAPP15','MAPP16','MAPP17','MAPP18',
                    'MHSMEMB', 'FTEMD', 'FTERES', 'ADMTOT', 'IPDTOT', 'MCDDC', 'MCRDC',
                    'FTERN', 'FTELPN', 'FTEH', 'NAMMSHOS', 'ACLABHOS', 'ENDOCHOS', 'ENDOUHOUS',
                    'REDSHOS', 'CTSCNHOS', 'DRADFHOS', 'EBCTHOS', 'FFDMHOS', 'MRIHOS', 'IMRIHOS',
                    'MSCTHOS', 'MSCTGHOS', 'PETHOS', 'PETCTHOS', 'SPECTHOS', 'ULTSNHOS',
                    'AMBSHOS', 'EMDEPHOS', 'ICLABHOS', 'ADTCHOS', 'ADTEHOS', 'CHTHHOS', 'CAOSHOS',
                    'ONCOLHO', 'RASTHOS', 'IMRTHOS', 'CICBD', 'NICBD', 'NINTBD', 'PEDICBD',
                    'BROOMHOS', 'ACLABHOS', 'CARIC', 'CTSCNHOS', 'DRADFHOS', 'ESWLHOS', 'FITCHOS',
                    'ADTCHOS', 'PETHOS', 'IGRTHOS', 'IMRTHOS', 'SPECTHOS', 'SPORTHOS', 'ULTSNHOS', 
                    'WOMHCHOS', 'ALCHBD', 'BRNBD', 'PSYBD', 'TRAUMHOS', 'PSYCAHOS', 'EMDEPHOS', 
                    'AIDSSHOS', 'PSYSLSHOS', 'PSYEDHOS', 'PSYEMHOS', 'PSYOPHOS', 'PSYPHHOS', 
                    'ADULTHOS', 'HOSPCHOS', 'PATEDHOS', 'SOCWKHOS', 'VOLSVHOS', 'GPWWHOS', 'OPHHOS', 
                    'CPHHOS', 'FNDHOS', 'EQMHOS', 'IPAHOS', 'MSOHOS', 'ISMHOS', 'GPWWNET', 'OPHNET', 
                    'ROBOHOS', 'ROBOSYS', 'ROBONET', 'ROBOVEN', 'PTONHOS', 'PTONSYS', 'PTONNET', 'PTONVEN',
                    'SRADHOS', 'SRADSYS', 'SRADNET', 'SRADVEN',                    
                    'CPHNET', 'FNDNET', 'EQMNET', 'IPANET', 'MSONET', 'ISMNET', 'GPWWSYS', 'OPHSYS', 
                    'CPHSYS', 'FNDSYS', 'EQMSYS', 'IPASYS', 'MSOSYS', 'ISMSYS', 'PHYGP',
                    'CAH','RRCTR','SCPROV'))) %>%
    mutate(year=y) %>%
    mutate(across(any_of(c('EHLTH','ACLABHOS','CTSCNHOS','DRADFHOS','EBCTHOS',
                    'FFDMHOS','MRIHOS','IMRIHOS','MSCTHOS','MSCTGHOS',
                    'PETHOS','PETCTHOS','SPECTHOS','ULTSNHOS','AMBSHOS',
                    'EMDEPHOS','ICLABHOS','ADTCHOS','CHTHHOS','CAOSHOS',
                    'IMRTHOS','BROOMHOS','ESWLHOS','FITCHOS',
                    'IGRTHOS','SPORTHOS','WOMHCHOS','TRAUMHOS','PSYCAHOS',
                    'AIDSSHOS','PSYEDHOS','PSYEMHOS','PSYOPHOS','PSYPHHOS',
                    'ADULTHOS','HOSPCHOS','PATEDHOS','SOCWKHOS','VOLSVHOS',
                    'GPWWHOS','IPAHOS','MSOHOS','ISMHOS','GPWWNET','IPANET',
                    'MSONET','ISMNET','GPWWSYS','IPASYS','MSOSYS','ISMSYS',
                    'ID','NPINUM','HRRCODE','SYSID','FSTCD','FCNTYCD',
                    'CAH','RRCTR','SCPROV','SERV','COMMTY','MLOS','MHSMEMB',
                    'ROBOHOS', 'ROBOSYS', 'ROBONET', 'ROBOVEN', 'PTONHOS', 'PTONSYS', 'PTONNET', 'PTONVEN',
                    'SRADHOS', 'SRADSYS', 'SRADNET', 'SRADVEN')), ~ as_factor(.)),
           across(any_of(c('LAT','LONG','SYSTELN','CICBD','NICBD', 'HSACODE',
                           'NINTBD','PEDICBD','ALCHBD','BRNBD','PSYBD')), ~ as.numeric(.)),
           across(any_of(c('DTBEG','DTEND','FISYR','MSTATE')), ~as.character(.))) %>%
      mutate(COMMTY=case_when(
        COMMTY==2 ~ "N",
        COMMTY==1 ~ "Y",
        TRUE ~ NA_character_))
  
  aha.modern <- bind_rows(aha.modern, aha.data)
  
}



# Tidy AHA data -----------------------------------------------------------

aha.final <- bind_rows(aha.historic, aha.modern) %>%
  mutate(
    critical_access = case_when(
      year<2003 ~ NA,
      year>=2003 & year<2009 & CAH==2 ~ 0,
      year>=2003 & year<2009 & CAH==1 ~ 1,
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
    teach_major = case_when(
      MAPP8==1 ~ 1,
      TRUE ~ 0),
    teach_minor = case_when(
      MAPP3==1 | MAPP5==1 | MAPP8==1 | MAPP12==1 | MAPP13==1 ~ 1,
      TRUE ~ 0),
    system=ifelse(!is.na(SYSID) | MHSMEMB==1, 1, 0)) %>%
  filter(!is.na(ID), ID!="", ID!="1111111") %>%
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

aha.closures.historic <- read_csv('data/input/AHA Data/AHA Summary of Changes 1986-2006/closures.csv') %>%
  mutate(year=year-1, ID=as.character(ID))

aha.merger.historic <- read_csv('data/input/AHA Data/AHA Summary of Changes 1986-2006/mergers.csv') %>%
  group_by(ID, year) %>%
  filter(row_number()==1) %>%
  ungroup() %>%
  mutate(year=year-1, ID=as.character(ID))

aha.new.historic <- read_csv('data/input/AHA Data/AHA Summary of Changes 1986-2006/new-hospitals.csv') %>%
  mutate(ID=as.character(ID))
  
aha.other.historic <- read_csv('data/input/AHA Data/AHA Summary of Changes 1986-2006/other-changes.csv') %>%
  mutate(year=year-1, ID=as.character(ID))

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
  mutate(change_source1="Summary of Changes", other_ID=as.character(other_ID)) %>%
  rename(change_reason=reason)

aha.all.changes.historic <- bind_rows(aha.closures.historic, aha.merger.historic, aha.new.historic, aha.other.historic) %>%
  arrange(ID, year) %>%
  group_by(ID) %>%
  mutate(change_count=row_number()) %>%
  ungroup() %>%
  mutate(change_source1="Summary of Changes")

aha.changes <- bind_rows(aha.all.changes, aha.all.changes.historic)


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

## fill missing values if they are observed and identical in the previous year and the subsequent year
factor_cols <- names(aha.final)[sapply(aha.final, is.factor)]

aha.final.edit <- aha.final %>%
  mutate(across(all_of(factor_cols), as.character))


# 1. Create datasets of lagged and lead years
aha.final.lag <- aha.final.edit %>% mutate(year = year + 1)
aha.final.lead <- aha.final.edit %>% mutate(year = year - 1)

# 2. Merge the datasets
merged_data <- aha.final.edit %>%
  left_join(aha.final.lag, by = c("ID", "year"), suffix = c("", ".lag")) %>%
  left_join(aha.final.lead, by = c("ID", "year"), suffix = c("", ".lead"))

# 3. Replace missing values in aha.final
merged_data <- merged_data %>%
  mutate(across(all_of(names(aha.final.edit)[-which(names(aha.final.edit) == "year")]), 
         ~ ifelse(
             is.na(.) & 
             !is.na(.[paste0(cur_column(), ".lag")]) & 
             !is.na(.[paste0(cur_column(), ".lead")]) & 
             .[paste0(cur_column(), ".lag")] == .[paste0(cur_column(), ".lead")], 
             .[paste0(cur_column(), ".lag")], 
             .
         )))

# Drop the extra columns and return to the original structure
aha.final2 <- merged_data %>% select(names(aha.final.edit)) %>%
  mutate(across(all_of(factor_cols), as.factor))



## count non-missing variables by year
non.missing.counts <- aha.final %>%
  group_by(year) %>%
  summarise(across(everything(), ~ sum(!is.na(.) & !(. %in% "")))) %>%
  pivot_longer(cols = -year, names_to = "Variable", values_to = "Count") %>%
  pivot_wider(names_from = year, values_from = Count)


aha.combine <- aha.final %>%
  left_join(aha.changes,
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

aha.geo  <- aha.combine %>%
  select(ID, SYSID, MCRNUM, NPINUM, LAT, LONG, FCNTYCD, FSTCD,
         MLOCCITY, MLOCZIP, MSTATE, MLOCAD1, MLOCAD2, year, 
         own_type, critical_access, change_type) %>%
  write_csv('data/output/aha_geo.csv')
