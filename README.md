# AHA Data

Code and supporting documentation for importing and cleaning data from the AHA Annual Survey, the AHA Summary of Changes, and (new) the AHA IT Supplement.

## Two pipelines

- **Legacy** — `data-code/_aha-data.R` and `data-code/_build-changes-data.R`. Produces frozen outputs at `data/output/{aha_data,aha_geo,df_change}.csv` covering 1980-2019. Multiple downstream projects symlink directly to those files; the frozen versions are preserved bit-for-bit for reproducibility of submitted manuscripts.

- **Update 2026** — `code/_build.R` + numbered sub-scripts (`code/1-historic.R` through `code/6-merge.R`). Produces refreshed outputs at `data/output/update-2026/{aha_data,aha_geo,aha_it}.csv` covering 1980-2024 plus a new IT Supplement panel.

## Folder layout

- **data/** — inputs (raw, symlinked from `D:/research-data/aha/`) and outputs (cleaned). `data/*` is gitignored.
- **data-code/** — legacy pipeline scripts (frozen).
    - `_aha-data.R` builds the legacy panel.
    - `_build-changes-data.R` + `sum_of_change-y.R` + `tidy_sum_of_change.R` + `pdf2table.ipynb` + `hardcoding.py` build `df_change.csv` from the 2007-2019 Summary of Changes PDFs. Currently produced but not used by `_aha-data.R`, which relies on the manually-collected 1986-2019 changes data.
- **code/** — refreshed pipeline. Driver `_build.R` loads packages and sources sub-scripts in order. Runs end-to-end in a few minutes against system R.

## Running the new pipeline

```r
source("code/_build.R")
```

Outputs land in `data/output/update-2026/`.
