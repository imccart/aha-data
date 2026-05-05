# AHA Data

Code for importing and cleaning the AHA Annual Survey, Summary of Changes, and IT Supplement.

## Outputs

In `data/output/`:

- `aha_data.csv` / `aha_geo.csv` — frozen 1980-2019 panel. Multiple downstream projects symlink to these files; preserved bit-for-bit for reproducibility of submitted manuscripts.
- `df_change.csv` — frozen Summary of Changes file used by the legacy build.
- `aha_data_1980-2024.csv` / `aha_geo_1980-2024.csv` — refreshed panel. Same column set as the frozen files plus 2020-2024.
- `aha_it_2008-2024.csv` — new IT Supplement panel (2008-2024).

Filenames carry their year coverage; future refreshes get a new vintage suffix rather than overwriting an existing file.

## Running the pipeline

```r
source("code/_build.R")
```

Sub-scripts:

- `code-lists.R` — shared variable lists / type maps
- `1-historic.R` — 1980-2006 from WRDS files
- `2-yearly.R` — 2007-2013 from per-year COMMA files
- `3-modern.R` — 2014-2024 from `aha-2014-2024.zip`
- `4-changes.R` — Summary of Changes (1986-2019, manually collected)
- `5-it.R` — IT Supplement (2008-2024)
- `6-merge.R` — combine + impute + write outputs

## Data sources

Symlinked from `D:/research-data/aha/`:

- `AHA FY 1980-1985`, `AHA FY 1986-1993`, `AHA FY 1994-2021` — WRDS historic CSVs
- `AHA FY 2007` through `AHA FY 2013` — per-year COMMA files
- `aha-2014-2024.zip` — single combined CSV, 1,987 cols, 2014-2024 (latin1 encoding required)
- `AHA Summary of Changes 1986-2019/` — manually collected closures, mergers, new-hospitals, other-changes
- `IT-supplement/IT_SURVEY.csv` — 2008-2020, 2022, UPPERCASE columns
- `IT-supplement/aha-it-2014-2024.zip` — 2022-2024, lowercase, supersedes IT_SURVEY for 2022
