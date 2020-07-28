# r2dii.match (development version)

User-facing

* New `crucial_lbk()` helps select the minimum loanbook columns for `match_name()` to run (#236).

* `match_name()` now returns the `rowid` column giving the row number of the input `loanbook` (#236). This allows users to save time and memory by feeding `match_name()` with only crucial columns. Then can later add the original loanbook columns to the matched output with

``` r
library(dplyr, warn.conflicts = FALSE)
library(r2dii.data)
library(r2dii.match)

lbk_full <- loanbook_demo
# Save time and memory: use just crucial columns
lbk_mini <- lbk_full %>% select(crucial_lbk())
ald <- ald_demo

out <- match_name(lbk_mini, ald)

dim(out)
#> [1] 497  15

# Recover all columns
all_cols <-  out %>% left_join(tibble::rowid_to_column(lbk_full), by = "rowid")

dim(all_cols)
#> [1] 497  34
```

* `match_name()` now runs faster and uses less memory (@georgeharris2deg #214).

Internal

* Lint.

# r2dii.match 0.0.3

* Enforce dplyr >= 0.8.5 (#216).
* No longer import vctrs; it is unused.

# r2dii.match 0.0.2

This version includes only [internal changes](https://github.com/2DegreesInvesting/r2dii.match/releases/tag/v0.0.2). 

# r2dii.match 0.0.1

* First release on CRAN.
