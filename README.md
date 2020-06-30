
<!-- README.md is generated from README.Rmd. Please edit that file -->

# r2dii.match <a href='https://github.com/2DegreesInvesting/r2dii.match'><img src='https://imgur.com/A5ASZPE.png' align='right' height='43' /></a>

<!-- badges: start -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/r2dii.match)](https://CRAN.R-project.org/package=r2dii.match)
[![](https://cranlogs.r-pkg.org/badges/grand-total/r2dii.match)](https://CRAN.R-project.org/package=r2dii.match)
[![Codecov test
coverage](https://codecov.io/gh/2degreesinvesting/r2dii.match/branch/master/graph/badge.svg)](https://codecov.io/gh/2degreesinvesting/r2dii.match?branch=master)
[![R build
status](https://github.com/2DegreesInvesting/r2dii.match/workflows/R-CMD-check/badge.svg)](https://github.com/2DegreesInvesting/r2dii.match/actions)
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
#> # A tibble: 502 x 27
#>    id_loan id_direct_loant… name_direct_loa… id_intermediate… name_intermedia…
#>    <chr>   <chr>            <chr>            <chr>            <chr>           
#>  1 L170    C203             Tesla Inc        <NA>             <NA>            
#>  2 L180    C217             Weichai Power C… <NA>             <NA>            
#>  3 L181    C218             Wheego           <NA>             <NA>            
#>  4 L195    C313             Zhengzhou Yuton… <NA>             <NA>            
#>  5 L174    C211             Tvr              <NA>             <NA>            
#>  6 L198    C317             Ziyang Nanjun    <NA>             <NA>            
#>  7 L193    C310             Zamyad           <NA>             <NA>            
#>  8 L165    C195             Sunwin Bus       <NA>             <NA>            
#>  9 L154    C171             Shandong Tangju… <NA>             <NA>            
#> 10 L164    C193             Subaru Corp      <NA>             <NA>            
#> # … with 492 more rows, and 22 more variables: id_ultimate_parent <chr>,
#> #   name_ultimate_parent <chr>, loan_size_outstanding <dbl>,
#> #   loan_size_outstanding_currency <chr>, loan_size_credit_limit <dbl>,
#> #   loan_size_credit_limit_currency <chr>, sector_classification_system <chr>,
#> #   sector_classification_input_type <chr>,
#> #   sector_classification_direct_loantaker <dbl>, fi_type <chr>,
#> #   flag_project_finance_loan <chr>, name_project <lgl>,
#> #   lei_direct_loantaker <lgl>, isin_direct_loantaker <lgl>, id_2dii <chr>,
#> #   level <chr>, sector <chr>, sector_ald <chr>, name <chr>, name_ald <chr>,
#> #   score <dbl>, source <chr>
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
#> # A tibble: 267 x 27
#>    id_loan id_direct_loant… name_direct_loa… id_intermediate… name_intermedia…
#>    <chr>   <chr>            <chr>            <chr>            <chr>           
#>  1 L151    C168             Shaanxi Auto     <NA>             <NA>            
#>  2 L152    C169             Shandong Auto    <NA>             <NA>            
#>  3 L153    C170             Shandong Kama    <NA>             <NA>            
#>  4 L154    C171             Shandong Tangju… <NA>             <NA>            
#>  5 L155    C173             Shanghai Automo… <NA>             <NA>            
#>  6 L156    C176             Shanxi Dayun     <NA>             <NA>            
#>  7 L157    C178             Shenyang Polars… <NA>             <NA>            
#>  8 L158    C180             Shuanghuan Auto  <NA>             <NA>            
#>  9 L159    C182             Sichuan Auto     <NA>             <NA>            
#> 10 L160    C184             Singulato        <NA>             <NA>            
#> # … with 257 more rows, and 22 more variables: id_ultimate_parent <chr>,
#> #   name_ultimate_parent <chr>, loan_size_outstanding <dbl>,
#> #   loan_size_outstanding_currency <chr>, loan_size_credit_limit <dbl>,
#> #   loan_size_credit_limit_currency <chr>, sector_classification_system <chr>,
#> #   sector_classification_input_type <chr>,
#> #   sector_classification_direct_loantaker <dbl>, fi_type <chr>,
#> #   flag_project_finance_loan <chr>, name_project <lgl>,
#> #   lei_direct_loantaker <lgl>, isin_direct_loantaker <lgl>, id_2dii <chr>,
#> #   level <chr>, sector <chr>, sector_ald <chr>, name <chr>, name_ald <chr>,
#> #   score <dbl>, source <chr>
```

The result is a dataset with identical columns to the input loanbook,
and added columns bridging all matched loans to their ald counterpart.

[Get
started](https://2degreesinvesting.github.io/r2dii.match/articles/r2dii-match.html).
