
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
[![Codecov test
coverage](https://codecov.io/gh/2degreesinvesting/r2dii.match/branch/master/graph/badge.svg)](https://codecov.io/gh/2degreesinvesting/r2dii.match?branch=master)
[![R build
status](https://github.com/2DegreesInvesting/r2dii.match/workflows/R-CMD-check/badge.svg)](https://github.com/2DegreesInvesting/r2dii.match/actions)
<!-- badges: end -->

The goal of r2dii.match is to match counterparties from a generic
loanbook data with physical asset level data (ald).

## Installation

Before you install r2dii.match you may want to:

  - [Try an rstudio.cloud project that has r2dii.match already
    installed](https://rstudio.cloud/project/954051).
  - [Learn how to minimize installation
    errors](https://gist.github.com/maurolepore/a0187be9d40aee95a43f20a85f4caed6#installation).

When you are ready, install the development version of r2dii.match from
GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("2DegreesInvesting/r2dii.match")
```

## Example

``` r
library(r2dii.match)
library(r2dii.dataraw)
#> Loading required package: r2dii.utils
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

The result is a dataset, with identical columns to the input loanbook,
and added columns bridging all matched loans to their ald counterpart.

For a more detailed walkthrough of the functionality [Get
started](FIXME)).
