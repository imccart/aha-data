# AHA Data

This repository houses code and other supporting documentation for importing and cleaning data from the AHA annual surveys, as well as information on hospital mergers and closures based on the AHA summary of changes files. The directory structure and description is listed below:

- **data**: includes descriptions of datasets used and links to raw sources where possible. This folder is separated into "inputs" (raw data) and "outputs" (clean data files available for analysis). There is also a "temp" subdirectory within the "outputs" folder to track intermediate outputs

- **data-code**: code files and supporting documentation for all data wrangling, cleaning, and management. 
    - Mergers, Closures, etc: 
        - `pdf2table.ipynb` transforms the tables in the 'summary of changes' pdf into csv files. The result might depend on the version of the packages used (especially `tabula.io`). This code is unnecessary if you already have 'change_{ }.csv' files in 'output/temp' folder.
        - `hardcoding.py` contains some objects and user-defined functions called in the `pdf2table.ipynb` file.
        - `_build-changes-data.R` generates 'df_change.csv' into 'output' directory.
            - `sum_of_change-y.R` generates R dataframe `sum_of_change` from the raw csv files of 'Summary of Changes'. It is assumed that the csv files for 'Summary of Changes' are already obtained (and stored in 'data/temp/') from 'pdf2table.ipynb'.
            - `tidy_sum_of_change.R` tidy the dataframe `sum_of_change`.
