
<!-- README.md is generated from README.Rmd. Please edit that file -->

# r2dii.match <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![CRAN
status](https://www.r-pkg.org/badges/version/r2dii.match)](https://CRAN.R-project.org/package=r2dii.match)
[![](https://cranlogs.r-pkg.org/badges/grand-total/r2dii.match)](https://CRAN.R-project.org/package=r2dii.match)
[![Codecov test
coverage](https://codecov.io/gh/RMI-PACTA/r2dii.match/branch/main/graph/badge.svg)](https://app.codecov.io/gh/RMI-PACTA/r2dii.match?branch=main)
[![R-CMD-check](https://github.com/RMI-PACTA/r2dii.match/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/RMI-PACTA/r2dii.match/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

These tools implement in R a fundamental part of the software PACTA
(Paris Agreement Capital Transition Assessment), which is a free tool
that calculates the alignment between financial portfolios and climate
scenarios (<https://www.transitionmonitor.com/>). Financial institutions
use PACTA to study how their capital allocation impacts the climate.
This package matches data from financial portfolios to asset level data
from market-intelligence databases (e.g. power plant capacities,
emission factors, etc.). This is the first step to assess if a financial
portfolio aligns with climate goals.

## Installation

Install the released version of r2dii.match from CRAN with:

``` r
# install.packages("r2dii.match")
```

Or install the development version of r2dii.match from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("RMI-PACTA/r2dii.match")
```

## Example

``` r
library(r2dii.data)
library(r2dii.match)
```

Matching is achieved in two main steps:

### 1. Run fuzzy matching

`match_name()` will extract all unique counterparty names from the
columns: `direct_loantaker`, `ultimate_parent` or `intermediate_parent*`
and run fuzzy matching against all company names in the `abcd`:

``` r
match_result <- match_name(loanbook_demo, abcd_demo)
match_result 
#> # A tibble: 26 × 28
#>    id_direct_loantaker name_direct_loantaker          id_intermediate_parent_1
#>    <chr>               <chr>                          <chr>                   
#>  1 C26                 large oil and gas company four <NA>                    
#>  2 C26                 large oil and gas company four <NA>                    
#>  3 C1                  large automotive company five  <NA>                    
#>  4 C1                  large automotive company five  <NA>                    
#>  5 C35                 large steel company five       <NA>                    
#>  6 C35                 large steel company five       <NA>                    
#>  7 C5                  large automotive company two   <NA>                    
#>  8 C5                  large automotive company two   <NA>                    
#>  9 C30                 large power company five       <NA>                    
#> 10 C30                 large power company five       <NA>                    
#> # ℹ 16 more rows
#> # ℹ 25 more variables: name_intermediate_parent_1 <chr>,
#> #   id_ultimate_parent <chr>, name_ultimate_parent <chr>,
#> #   loan_size_outstanding <dbl>, loan_size_outstanding_currency <chr>,
#> #   loan_size_credit_limit <dbl>, loan_size_credit_limit_currency <chr>,
#> #   sector_classification_system <chr>, sector_classification_input_type <chr>,
#> #   sector_classification_direct_loantaker <dbl>, fi_type <chr>, …
```

### 2. Prioritize validated matches

The user should then manually validate the output of \[match_name()\],
ensuring that the value of the column `score` is equal to `1` for
perfect matches only.

Once validated, the `prioritize()` function, will choose only the valid
matches, prioritizing (by default) `direct_loantaker` matches over
`ultimate_parent` matches:

``` r
prioritize(match_result)
#> # A tibble: 13 × 28
#>    id_direct_loantaker name_direct_loantaker          id_intermediate_parent_1
#>    <chr>               <chr>                          <chr>                   
#>  1 C26                 large oil and gas company four <NA>                    
#>  2 C1                  large automotive company five  <NA>                    
#>  3 C35                 large steel company five       <NA>                    
#>  4 C5                  large automotive company two   <NA>                    
#>  5 C30                 large power company five       <NA>                    
#>  6 C3                  large automotive company one   <NA>                    
#>  7 C23                 large hdv company three        <NA>                    
#>  8 C33                 large power company three      <NA>                    
#>  9 C31                 large power company four       <NA>                    
#> 10 C32                 large power company one        <NA>                    
#> 11 C34                 large power company two        <NA>                    
#> 12 C25                 large oil and gas company five <NA>                    
#> 13 C20                 large coal company two         <NA>                    
#> # ℹ 25 more variables: name_intermediate_parent_1 <chr>,
#> #   id_ultimate_parent <chr>, name_ultimate_parent <chr>,
#> #   loan_size_outstanding <dbl>, loan_size_outstanding_currency <chr>,
#> #   loan_size_credit_limit <dbl>, loan_size_credit_limit_currency <chr>,
#> #   sector_classification_system <chr>, sector_classification_input_type <chr>,
#> #   sector_classification_direct_loantaker <dbl>, fi_type <chr>,
#> #   flag_project_finance_loan <chr>, name_project <chr>, …
```

The result is a dataset with identical columns to the input loanbook,
and added columns bridging all matched loans to their abcd counterpart.

[Get
started](https://rmi-pacta.github.io/r2dii.match/articles/r2dii-match.html).

## Funding

This project has received funding from the [European Union LIFE
program](https://wayback.archive-it.org/12090/20210412123959/https://ec.europa.eu/easme/en/)
and the International Climate Initiative (IKI). The Federal Ministry for
the Environment, Nature Conservation and Nuclear Safety (BMU) supports
this initiative on the basis of a decision adopted by the German
Bundestag. The views expressed are the sole responsibility of the
authors and do not necessarily reflect the views of the funders. The
funders are not responsible for any use that may be made of the
information it contains.
