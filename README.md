
<!-- README.md is generated from README.Rmd. Please edit that file -->

# r2dii.match <a href='https://github.com/2DegreesInvesting/r2dii.match'><img src='https://imgur.com/A5ASZPE.png' align='right' height='43' /></a>

<!-- badges: start -->

[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![CRAN
status](https://www.r-pkg.org/badges/version/r2dii.match)](https://CRAN.R-project.org/package=r2dii.match)
[![](https://cranlogs.r-pkg.org/badges/grand-total/r2dii.match)](https://CRAN.R-project.org/package=r2dii.match)
[![Codecov test
coverage](https://codecov.io/gh/2degreesinvesting/r2dii.match/branch/master/graph/badge.svg)](https://codecov.io/gh/2degreesinvesting/r2dii.match?branch=master)
[![R build
status](https://github.com/2degreesinvesting/r2dii.match/workflows/R-CMD-check/badge.svg)](https://github.com/2degreesinvesting/r2dii.match/actions)
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

Before you install r2dii.match you may want to:

  - [Try an rstudio.cloud project with this package already
    installed](https://rstudio.cloud/project/1424833).
  - [Learn how to minimize installation
    errors](https://gist.github.com/maurolepore/a0187be9d40aee95a43f20a85f4caed6#installation).

When you are ready, install the released version of r2dii.match from
CRAN with:

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

### 1\. Run fuzzy matching

`match_name()` will extract all unique counterparty names from the
columns: `direct_loantaker`, `ultimate_parent` or `intermediate_parent*`
and run fuzzy matching against all company names in the `ald`:

``` r
match_result <- match_name(loanbook_demo, ald_demo)
match_result 
#> [90m# A tibble: 502 x 28[39m
#>    id_loan id_direct_loant… name_direct_loa… id_intermediate… name_intermedia…
#>    [3m[90m<chr>[39m[23m   [3m[90m<chr>[39m[23m            [3m[90m<chr>[39m[23m            [3m[90m<chr>[39m[23m            [3m[90m<chr>[39m[23m           
#> [90m 1[39m L1      C294             Yuamen Xinneng … [31mNA[39m               [31mNA[39m              
#> [90m 2[39m L3      C292             Yuama Ethanol L… IP5              Yuama Inc.      
#> [90m 3[39m L3      C292             Yuama Ethanol L… IP5              Yuama Inc.      
#> [90m 4[39m L5      C305             Yukon Energy Co… [31mNA[39m               [31mNA[39m              
#> [90m 5[39m L5      C305             Yukon Energy Co… [31mNA[39m               [31mNA[39m              
#> [90m 6[39m L6      C304             Yukon Developme… [31mNA[39m               [31mNA[39m              
#> [90m 7[39m L6      C304             Yukon Developme… [31mNA[39m               [31mNA[39m              
#> [90m 8[39m L8      C303             Yueyang City Co… [31mNA[39m               [31mNA[39m              
#> [90m 9[39m L9      C301             Yuedxiu Corp One IP10             Yuedxiu Group   
#> [90m10[39m L10     C302             Yuexi County AA… [31mNA[39m               [31mNA[39m              
#> [90m# … with 492 more rows, and 23 more variables: id_ultimate_parent [3m[90m<chr>[90m[23m,[39m
#> [90m#   name_ultimate_parent [3m[90m<chr>[90m[23m, loan_size_outstanding [3m[90m<dbl>[90m[23m,[39m
#> [90m#   loan_size_outstanding_currency [3m[90m<chr>[90m[23m, loan_size_credit_limit [3m[90m<dbl>[90m[23m,[39m
#> [90m#   loan_size_credit_limit_currency [3m[90m<chr>[90m[23m, sector_classification_system [3m[90m<chr>[90m[23m,[39m
#> [90m#   sector_classification_input_type [3m[90m<chr>[90m[23m,[39m
#> [90m#   sector_classification_direct_loantaker [3m[90m<dbl>[90m[23m, fi_type [3m[90m<chr>[90m[23m,[39m
#> [90m#   flag_project_finance_loan [3m[90m<chr>[90m[23m, name_project [3m[90m<lgl>[90m[23m,[39m
#> [90m#   lei_direct_loantaker [3m[90m<lgl>[90m[23m, isin_direct_loantaker [3m[90m<lgl>[90m[23m, id_2dii [3m[90m<chr>[90m[23m,[39m
#> [90m#   level [3m[90m<chr>[90m[23m, sector [3m[90m<chr>[90m[23m, sector_ald [3m[90m<chr>[90m[23m, name [3m[90m<chr>[90m[23m, name_ald [3m[90m<chr>[90m[23m,[39m
#> [90m#   score [3m[90m<dbl>[90m[23m, source [3m[90m<chr>[90m[23m, borderline [3m[90m<lgl>[90m[23m[39m
```

### 2\. Prioritize validated matches

The user should then manually validate the output of \[match\_name()\],
ensuring that the value of the column `score` is equal to `1` for
perfect matches only.

Once validated, the `prioritize()` function, will choose only the valid
matches, prioritizing (by default) `direct_loantaker` matches over
`ultimate_parent` matches:

``` r
prioritize(match_result)
#> [90m# A tibble: 267 x 28[39m
#>    id_loan id_direct_loant… name_direct_loa… id_intermediate… name_intermedia…
#>    [3m[90m<chr>[39m[23m   [3m[90m<chr>[39m[23m            [3m[90m<chr>[39m[23m            [3m[90m<chr>[39m[23m            [3m[90m<chr>[39m[23m           
#> [90m 1[39m L6      C304             Yukon Developme… [31mNA[39m               [31mNA[39m              
#> [90m 2[39m L13     C297             Yuba City Cogen… [31mNA[39m               [31mNA[39m              
#> [90m 3[39m L20     C287             Ytl Powerseraya… [31mNA[39m               [31mNA[39m              
#> [90m 4[39m L21     C286             Ytl Power Inter… [31mNA[39m               [31mNA[39m              
#> [90m 5[39m L22     C285             Ytl Corp Bhd     [31mNA[39m               [31mNA[39m              
#> [90m 6[39m L23     C283             Ypic Internatio… [31mNA[39m               [31mNA[39m              
#> [90m 7[39m L24     C282             Ypfb Corporacion [31mNA[39m               [31mNA[39m              
#> [90m 8[39m L25     C281             Ypf Sa           [31mNA[39m               [31mNA[39m              
#> [90m 9[39m L26     C280             Ypf Energia Ele… [31mNA[39m               [31mNA[39m              
#> [90m10[39m L27     C278             Younicos Ag      [31mNA[39m               [31mNA[39m              
#> [90m# … with 257 more rows, and 23 more variables: id_ultimate_parent [3m[90m<chr>[90m[23m,[39m
#> [90m#   name_ultimate_parent [3m[90m<chr>[90m[23m, loan_size_outstanding [3m[90m<dbl>[90m[23m,[39m
#> [90m#   loan_size_outstanding_currency [3m[90m<chr>[90m[23m, loan_size_credit_limit [3m[90m<dbl>[90m[23m,[39m
#> [90m#   loan_size_credit_limit_currency [3m[90m<chr>[90m[23m, sector_classification_system [3m[90m<chr>[90m[23m,[39m
#> [90m#   sector_classification_input_type [3m[90m<chr>[90m[23m,[39m
#> [90m#   sector_classification_direct_loantaker [3m[90m<dbl>[90m[23m, fi_type [3m[90m<chr>[90m[23m,[39m
#> [90m#   flag_project_finance_loan [3m[90m<chr>[90m[23m, name_project [3m[90m<lgl>[90m[23m,[39m
#> [90m#   lei_direct_loantaker [3m[90m<lgl>[90m[23m, isin_direct_loantaker [3m[90m<lgl>[90m[23m, id_2dii [3m[90m<chr>[90m[23m,[39m
#> [90m#   level [3m[90m<chr>[90m[23m, sector [3m[90m<chr>[90m[23m, sector_ald [3m[90m<chr>[90m[23m, name [3m[90m<chr>[90m[23m, name_ald [3m[90m<chr>[90m[23m,[39m
#> [90m#   score [3m[90m<dbl>[90m[23m, source [3m[90m<chr>[90m[23m, borderline [3m[90m<lgl>[90m[23m[39m
```

The result is a dataset with identical columns to the input loanbook,
and added columns bridging all matched loans to their ald counterpart.

[Get
started](https://2degreesinvesting.github.io/r2dii.match/articles/r2dii-match.html).

## Funding

This project has received funding from the [European Union LIFE
program](https://ec.europa.eu/easme/en/life) and the [International
Climate Initiative
(IKI)](https://www.international-climate-initiative.com/en/details/project/measuring-paris-agreement-alignment-and-financial-risk-in-financial-markets-18_I_351-2982).
The Federal Ministry for the Environment, Nature Conservation and
Nuclear Safety (BMU) supports this initiative on the basis of a decision
adopted by the German Bundestag. The views expressed are the sole
responsibility of the authors and do not necessarily reflect the views
of the funders. The funders are not responsible for any use that may be
made of the information it contains.
