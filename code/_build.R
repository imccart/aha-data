# Meta --------------------------------------------------------------------

## Author:        Ian McCarthy
## Date Created:  2026-05-05
## Date Edited:   2026-05-05
## Description:   Build AHA panel through 2024 plus IT supplement. Outputs
##                land in data/output/update-2026/. The legacy outputs in
##                data/output/{aha_data,aha_geo,df_change}.csv are produced
##                by data-code/_aha-data.R and frozen for reproducibility of
##                downstream projects.


# Packages ----------------------------------------------------------------

pacman::p_load(tidyverse, data.table, janitor)


# Call individual code files ----------------------------------------------

source("code/code-lists.R")     # shared variable lists / type maps

source("code/1-historic.R")     # 1980-2006 from WRDS files
source("code/2-yearly.R")       # 2007-2013 from per-year files
source("code/3-modern.R")       # 2014-2024 from aha-2014-2024 single file
source("code/4-changes.R")      # historic Summary of Changes (1986-2019)
source("code/5-it.R")           # IT supplement (2008-2024)
source("code/6-merge.R")        # combine + impute + write outputs

message("Build complete.")
