
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://i.imgur.com/3jITMq8.png" align="right" height=40 /> Match loanbook with asset level data

<!-- badges: start -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/r2dii.match)](https://CRAN.R-project.org/package=r2dii.match)
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
#> # A tibble: 320 x 18
#>    id_loan id_direct_loant~ name_direct_loa~ id_ultimate_par~
#>    <chr>   <chr>            <chr>            <chr>           
#>  1 L1      C294             Yuamen Xinneng ~ UP15            
#>  2 L2      C293             Yuamen Changyua~ UP84            
#>  3 L3      C292             Yuama Ethanol L~ UP288           
#>  4 L4      C299             Yudaksel Holdin~ UP54            
#>  5 L5      C305             Yukon Energy Co~ UP104           
#>  6 L6      C304             Yukon Developme~ UP83            
#>  7 L7      C227             Yaugoa-Zapadnay~ UP134           
#>  8 L8      C303             Yueyang City Co~ UP163           
#>  9 L9      C301             Yuedxiu Group    UP138           
#> 10 L10     C302             Yuexi County AA~ UP32            
#> # ... with 310 more rows, and 14 more variables:
#> #   name_ultimate_parent <chr>, loan_size_outstanding <dbl>,
#> #   loan_size_outstanding_currency <chr>, loan_size_credit_limit <dbl>,
#> #   loan_size_credit_limit_currency <chr>,
#> #   sector_classification_system <chr>,
#> #   sector_classification_input_type <chr>,
#> #   sector_classification_direct_loantaker <dbl>, fi_type <chr>,
#> #   flag_project_finance_loan <chr>, name_intermediate_parent <lgl>,
#> #   name_project <lgl>, lei_direct_loantaker <lgl>,
#> #   isin_direct_loantaker <lgl>

some_customer_names <- c("3M Company", "Abbott Laboratories", "AbbVie Inc.")
replace_customer_name(some_customer_names)
#> [1] "threem co"          "abbottlaboratories" "abbvie inc"
```
