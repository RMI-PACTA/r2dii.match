
<!-- README.md is generated from README.Rmd. Please edit that file -->

# r2dii.match <img src="man/figures/logo.png" align="right" width="120" />

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
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
# install.packages("pak")
pak::pak("RMI-PACTA/r2dii.match")
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
#> # A tibble: 329 × 28
#>    id_loan id_direct_loantaker name_direct_loantaker      id_intermediate_pare…¹
#>    <chr>   <chr>               <chr>                      <chr>                 
#>  1 L1      C294                Vitale Group               <NA>                  
#>  2 L3      C292                Rowe-Rowe                  IP5                   
#>  3 L5      C305                Ring AG & Co. KGaA         <NA>                  
#>  4 L6      C304                Kassulke-Kassulke          <NA>                  
#>  5 L6      C304                Kassulke-Kassulke          <NA>                  
#>  6 L7      C227                Morissette Group           <NA>                  
#>  7 L7      C227                Morissette Group           <NA>                  
#>  8 L8      C303                Barone s.r.l.              <NA>                  
#>  9 L9      C301                Werner Werner AG & Co. KG… IP10                  
#> 10 L9      C301                Werner Werner AG & Co. KG… IP10                  
#> # ℹ 319 more rows
#> # ℹ abbreviated name: ¹​id_intermediate_parent_1
#> # ℹ 24 more variables: name_intermediate_parent_1 <chr>,
#> #   id_ultimate_parent <chr>, name_ultimate_parent <chr>,
#> #   loan_size_outstanding <dbl>, loan_size_outstanding_currency <chr>,
#> #   loan_size_credit_limit <dbl>, loan_size_credit_limit_currency <chr>,
#> #   sector_classification_system <chr>, …
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
#> # A tibble: 177 × 28
#>    id_loan id_direct_loantaker name_direct_loantaker      id_intermediate_pare…¹
#>    <chr>   <chr>               <chr>                      <chr>                 
#>  1 L6      C304                Kassulke-Kassulke          <NA>                  
#>  2 L13     C297                Ladeck                     <NA>                  
#>  3 L20     C287                Weinhold                   <NA>                  
#>  4 L21     C286                Gallo Group                <NA>                  
#>  5 L22     C285                Austermuhle GmbH           <NA>                  
#>  6 L24     C282                Ferraro-Ferraro Group      <NA>                  
#>  7 L25     C281                Lockman, Lockman and Lock… <NA>                  
#>  8 L26     C280                Ankunding, Ankunding and … <NA>                  
#>  9 L27     C278                Donati-Donati Group        <NA>                  
#> 10 L28     C276                Ferraro, Ferraro e Ferrar… <NA>                  
#> # ℹ 167 more rows
#> # ℹ abbreviated name: ¹​id_intermediate_parent_1
#> # ℹ 24 more variables: name_intermediate_parent_1 <chr>,
#> #   id_ultimate_parent <chr>, name_ultimate_parent <chr>,
#> #   loan_size_outstanding <dbl>, loan_size_outstanding_currency <chr>,
#> #   loan_size_credit_limit <dbl>, loan_size_credit_limit_currency <chr>,
#> #   sector_classification_system <chr>, …
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
