# AHA Data

This repository houses code and other supporting documentation for importing and cleaning data from the AHA annual surveys, as well as information on hospital mergers and closures based on the AHA summary of changes files. The directory structure and description is listed below:

- **data**: includes descriptions of datasets used and links to raw sources where possible. This folder is separated into "inputs" (raw data) and "outputs" (clean data files available for analysis). The subdirectories are currently structured as follows.
    - cooper-et-al: replication code and data
    - input
    - output: final data for analysis
    - sumofchanges: A collection of 'summary of changes'. For later years, I manually printed the relevant pages from 'AnnualSurveyFY{year}Doc.pdf'.
    - temp: intermediate outputs

- **data-code**: code files and supporting documentation for all data wrangling, cleaning, and management. All code files are called by the [_build-data.R](data-code/_build-data.R) script.
    - `pdf2table.ipynb` transforms the tables in the 'summary of changes' pdf into csv files. The result might depend on the version of the packages used (especially `tabula.io`). This code is unnecessary if you already have 'change_{ }.csv' files in 'temp' folder.
    - `_build_data.R` generates 'df_change2.csv' into 'output' directory.
