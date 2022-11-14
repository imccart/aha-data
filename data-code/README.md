- 'pdf2table.ipynb' transforms the tables in 'Summary of Changes {YEAR}' into csv files. The result might depend on the version of the package used (especially tabula-io). Mostly hardcoded because of the inconsistency of the data format.
    - 'hardcoding.py' contains some objects and user-defined functions for the above file.

- '_build-data.R' is the master file for the R codes.
    - 'sum_of_change-y.R' generates R dataframe `sum_of_change` from the raw csv files of 'Summary of Changes'. It is assumed that the csv files for 'Summary of Changes' are already obtained (and stored in 'data/temp/') from 'pdf2table.ipynb'.
    - 'tidy_sum_of_change.R' tidy the dataframe `sum_of_change`.
