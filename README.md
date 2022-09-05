
<!-- README.md is generated from README.Rmd. Please edit that file -->

# r2dii.match <img src="man/figures/logo.svg" align="right" width="120" />

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![CRAN
status](https://www.r-pkg.org/badges/version/r2dii.match)](https://CRAN.R-project.org/package=r2dii.match)
[![](https://cranlogs.r-pkg.org/badges/grand-total/r2dii.match)](https://CRAN.R-project.org/package=r2dii.match)
[![Codecov test
coverage](https://codecov.io/gh/2DegreesInvesting/r2dii.match/branch/main/graph/badge.svg)](https://app.codecov.io/gh/2DegreesInvesting/r2dii.match?branch=main)
[![R-CMD-check](https://github.com/2DegreesInvesting/r2dii.match/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/2DegreesInvesting/r2dii.match/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

These tools implement in R a fundamental part of the software PACTA
(Paris Agreement Capital Transition Assessment), which is a free tool
that calculates the alignment between financial portfolios and climate
scenarios (<https://2degrees-investing.org/>). Financial institutions
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
devtools::install_github("2DegreesInvesting/r2dii.match")
```

[How to raise an
issue?](https://2degreesinvesting.github.io/posts/2020-06-26-instructions-to-raise-an-issue/)

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
#> # A tibble: 410 × 28
#>    id_loan id_direct_l…¹ name_…² id_in…³ name_…⁴ id_ul…⁵ name_…⁶ loan_…⁷ loan_…⁸
#>    <chr>   <chr>         <chr>   <chr>   <chr>   <chr>   <chr>     <dbl> <chr>  
#>  1 L1      C294          Yuamen… <NA>    <NA>    UP15    Alpine…  225625 EUR    
#>  2 L3      C292          Yuama … IP5     Yuama … UP288   Univer…  410297 EUR    
#>  3 L3      C292          Yuama … IP5     Yuama … UP288   Univer…  410297 EUR    
#>  4 L5      C305          Yukon … <NA>    <NA>    UP104   Garlan…  406585 EUR    
#>  5 L5      C305          Yukon … <NA>    <NA>    UP104   Garlan…  406585 EUR    
#>  6 L6      C304          Yukon … <NA>    <NA>    UP83    Earthp…  185721 EUR    
#>  7 L6      C304          Yukon … <NA>    <NA>    UP83    Earthp…  185721 EUR    
#>  8 L8      C303          Yueyan… <NA>    <NA>    UP163   Kraftw…  291513 EUR    
#>  9 L9      C301          Yuedxi… IP10    Yuedxi… UP138   Jai Bh…  407513 EUR    
#> 10 L10     C302          Yuexi … <NA>    <NA>    UP32    Bhagwa…  186649 EUR    
#> # … with 400 more rows, 19 more variables: loan_size_credit_limit <dbl>,
#> #   loan_size_credit_limit_currency <chr>, sector_classification_system <chr>,
#> #   sector_classification_input_type <chr>,
#> #   sector_classification_direct_loantaker <dbl>, fi_type <chr>,
#> #   flag_project_finance_loan <chr>, name_project <lgl>,
#> #   lei_direct_loantaker <lgl>, isin_direct_loantaker <lgl>, id_2dii <chr>,
#> #   level <chr>, sector <chr>, sector_abcd <chr>, name <chr>, …
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
#> # A tibble: 216 × 28
#>    id_loan id_direct_l…¹ name_…² id_in…³ name_…⁴ id_ul…⁵ name_…⁶ loan_…⁷ loan_…⁸
#>    <chr>   <chr>         <chr>   <chr>   <chr>   <chr>   <chr>     <dbl> <chr>  
#>  1 L6      C304          Yukon … <NA>    <NA>    UP83    Earthp…  185721 EUR    
#>  2 L13     C297          Yuba C… <NA>    <NA>    UP69    Consor…  200569 EUR    
#>  3 L20     C287          Ytl Po… <NA>    <NA>    UP35    Bnb Re…  308217 EUR    
#>  4 L21     C286          Ytl Po… <NA>    <NA>    UP63    Cisa S…  226553 EUR    
#>  5 L22     C285          Ytl Co… <NA>    <NA>    UP187   Mr. La…  196857 EUR    
#>  6 L23     C283          Ypic I… <NA>    <NA>    UP297   Wallen…  195929 EUR    
#>  7 L24     C282          Ypfb C… <NA>    <NA>    UP209   Phoeni…  309145 EUR    
#>  8 L25     C281          Ypf Sa  <NA>    <NA>    UP296   Viridi…  266457 EUR    
#>  9 L26     C280          Ypf En… <NA>    <NA>    UP67    Coast …  199641 EUR    
#> 10 L27     C278          Younic… <NA>    <NA>    UP45    Ce Ene…  197785 EUR    
#> # … with 206 more rows, 19 more variables: loan_size_credit_limit <dbl>,
#> #   loan_size_credit_limit_currency <chr>, sector_classification_system <chr>,
#> #   sector_classification_input_type <chr>,
#> #   sector_classification_direct_loantaker <dbl>, fi_type <chr>,
#> #   flag_project_finance_loan <chr>, name_project <lgl>,
#> #   lei_direct_loantaker <lgl>, isin_direct_loantaker <lgl>, id_2dii <chr>,
#> #   level <chr>, sector <chr>, sector_abcd <chr>, name <chr>, …
```

The result is a dataset with identical columns to the input loanbook,
and added columns bridging all matched loans to their abcd counterpart.

[Get
started](https://2degreesinvesting.github.io/r2dii.match/articles/r2dii-match.html).

## Funding

This project has received funding from the [European Union LIFE
program](https://wayback.archive-it.org/12090/20210412123959/https://ec.europa.eu/easme/en/)
and the [International Climate Initiative
(IKI)](https://www.international-climate-initiative.com/en/search-project/).
The Federal Ministry for the Environment, Nature Conservation and
Nuclear Safety (BMU) supports this initiative on the basis of a decision
adopted by the German Bundestag. The views expressed are the sole
responsibility of the authors and do not necessarily reflect the views
of the funders. The funders are not responsible for any use that may be
made of the information it contains.
