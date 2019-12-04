
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://i.imgur.com/3jITMq8.png" align="right" height=40 /> Match loanbook with asset level data

<!-- badges: start -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/r2dii.match)](https://CRAN.R-project.org/package=r2dii.match)
[![Travis build
status](https://travis-ci.org/2DegreesInvesting/r2dii.match.svg?branch=master)](https://travis-ci.org/2DegreesInvesting/r2dii.match)
[![Coveralls test
coverage](https://coveralls.io/repos/github/2DegreesInvesting/r2dii.match/badge.svg)](https://coveralls.io/r/2DegreesInvesting/r2dii.match?branch=master)
<!-- badges: end -->

The goal of r2dii.match is to match loanbook data with asset level data.

## Installation

Install the development version of r2dii.match with something like this:

``` r
# install.packages("devtools")

# To install from a private repo, see ?usethis::browse_github_token()
devtools::install_github("2DegreesInvesting/r2dii.match", auth_token = "abc")
```

## Example

``` r
library(r2dii.match)

a_loanbook <- r2dii.dataraw::loanbook_demo
id_by_loantaker_sector(a_loanbook)
#> # A tibble: 320 x 19
#>    id_loan id_direct_loant~ name_direct_loa~ id_intermediate~ name_intermedia~
#>    <chr>   <chr>            <chr>            <chr>            <chr>           
#>  1 L1      C294             Yuamen Xinneng ~ <NA>             <NA>            
#>  2 L2      C293             Yuamen Changyua~ <NA>             <NA>            
#>  3 L3      C292             Yuama Ethanol L~ IP5              Yuama Inc.      
#>  4 L4      C299             Yudaksel Holdin~ <NA>             <NA>            
#>  5 L5      C305             Yukon Energy Co~ <NA>             <NA>            
#>  6 L6      C304             Yukon Developme~ <NA>             <NA>            
#>  7 L7      C227             Yaugoa-Zapadnay~ <NA>             <NA>            
#>  8 L8      C303             Yueyang City Co~ <NA>             <NA>            
#>  9 L9      C301             Yuedxiu Corp One IP10             Yuedxiu Group   
#> 10 L10     C302             Yuexi County AA~ <NA>             <NA>            
#> # ... with 310 more rows, and 14 more variables: id_ultimate_parent <chr>,
#> #   name_ultimate_parent <chr>, loan_size_outstanding <dbl>,
#> #   loan_size_outstanding_currency <chr>, loan_size_credit_limit <dbl>,
#> #   loan_size_credit_limit_currency <chr>, sector_classification_system <chr>,
#> #   sector_classification_input_type <chr>,
#> #   sector_classification_direct_loantaker <dbl>, fi_type <chr>,
#> #   flag_project_finance_loan <chr>, name_project <lgl>,
#> #   lei_direct_loantaker <lgl>, isin_direct_loantaker <lgl>

some_customer_names <- c("3M Company", "Abbott Laboratories", "AbbVie Inc.")
replace_customer_name(some_customer_names)
#> [1] "threem co"          "abbottlaboratories" "abbvie inc"
```
