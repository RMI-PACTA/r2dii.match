
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

The goal of r2dii.match is to match generic loanbook data with physical
asset level data (ald).

## Installation

Install the development version of r2dii.match with something like this:

``` r
# install.packages("devtools")

# To install from a private repo, see ?usethis::browse_github_token()
devtools::install_github("2DegreesInvesting/r2dii.match", auth_token = "abc")
```

## Example

As usual, we start by using required packages. For convenience we’ll
also use the tidyverse.

``` r
library(r2dii.match)
library(r2dii.dataraw)
#> Loading required package: r2dii.utils
library(tidyverse)
#> -- Attaching packages ------------------------------------------------ tidyverse 1.3.0 --
#> v ggplot2 3.2.1     v purrr   0.3.3
#> v tibble  2.1.3     v dplyr   0.8.3
#> v tidyr   1.0.0     v stringr 1.4.0
#> v readr   1.3.1     v forcats 0.4.0
#> -- Conflicts --------------------------------------------------- tidyverse_conflicts() --
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
```

We’ll use some fake datasets from the r2dii.dataraw package, which name
ends with `_demo`, for example:

``` r
loanbook_demo
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
```

Before matching, both the loanbook and asset level data must be
prepared.

``` r
loanbook <- prepare_loanbook_for_matching(loanbook_demo)
asset_level_data <- prepare_ald_for_matching(ald_demo)
```

`match_all_against_all()` scores the similarity between `simpler_name`
values in the prepared loanbook and ald datasets.

``` r
matched_by_sector <- match_all_against_all(loanbook, asset_level_data)

matched_by_sector
#> # A tibble: 64,457 x 3
#>    simpler_name_x simpler_name_y            score
#>    <chr>          <chr>                     <dbl>
#>  1 astonmartin    astonmartin               1    
#>  2 astonmartin    avtozaz                   0.681
#>  3 astonmartin    bogdan                    0.480
#>  4 astonmartin    chauto                    0.591
#>  5 astonmartin    chehejia                  0.311
#>  6 astonmartin    chtcauto                  0.455
#>  7 astonmartin    dongfenghonda             0.501
#>  8 astonmartin    dongfengluxgen            0.496
#>  9 astonmartin    electricmobilitysolutions 0.456
#> 10 astonmartin    faradayfuture             0.474
#> # ... with 64,447 more rows
```

By default, names are compared against ald names in the same sector.
`by_sector = FALSE` increases the matching runtime on large datasets,
and the amount of nonsensical matches.

``` r
match_all_against_all(
  loanbook, asset_level_data, 
  by_sector = FALSE
)
#> # A tibble: 308,228 x 3
#>    simpler_name_x         simpler_name_y                score
#>    <chr>                  <chr>                         <dbl>
#>  1 abahydropowergenco ltd abahydropowergenco ltd        1    
#>  2 abahydropowergenco ltd achinskyglinoziemskijkombinat 0.535
#>  3 abahydropowergenco ltd affinityrenewables inc        0.598
#>  4 abahydropowergenco ltd africaoil corp                0.599
#>  5 abahydropowergenco ltd africonshp sa                 0.581
#>  6 abahydropowergenco ltd agnisteelsprivate ltd         0.535
#>  7 abahydropowergenco ltd agrenewables                  0.615
#>  8 abahydropowergenco ltd airasiaxbhd                   0.545
#>  9 abahydropowergenco ltd airbaltic                     0.545
#> 10 abahydropowergenco ltd airblue                       0.551
#> # ... with 308,218 more rows
```

You can recover the `sector` column from the `loanbook` and `ald`
dataset with `dplyr::left_join()`:

``` r
matched_by_sector %>% 
  left_join(loanbook, by = c("simpler_name_x" = "simpler_name"))
#> # A tibble: 66,156 x 8
#>    simpler_name_x simpler_name_y     score level    id    name    sector  source
#>    <chr>          <chr>              <dbl> <chr>    <chr> <chr>   <chr>   <chr> 
#>  1 astonmartin    astonmartin        1     ultimat~ UP23  Aston ~ automo~ loanb~
#>  2 astonmartin    avtozaz            0.681 ultimat~ UP23  Aston ~ automo~ loanb~
#>  3 astonmartin    bogdan             0.480 ultimat~ UP23  Aston ~ automo~ loanb~
#>  4 astonmartin    chauto             0.591 ultimat~ UP23  Aston ~ automo~ loanb~
#>  5 astonmartin    chehejia           0.311 ultimat~ UP23  Aston ~ automo~ loanb~
#>  6 astonmartin    chtcauto           0.455 ultimat~ UP23  Aston ~ automo~ loanb~
#>  7 astonmartin    dongfenghonda      0.501 ultimat~ UP23  Aston ~ automo~ loanb~
#>  8 astonmartin    dongfengluxgen     0.496 ultimat~ UP23  Aston ~ automo~ loanb~
#>  9 astonmartin    electricmobilitys~ 0.456 ultimat~ UP23  Aston ~ automo~ loanb~
#> 10 astonmartin    faradayfuture      0.474 ultimat~ UP23  Aston ~ automo~ loanb~
#> # ... with 66,146 more rows
```

You can also recover the `sector` column from the `ald` dataset with a
similar strategy:

``` r
matched_by_sector %>% 
  left_join(loanbook, by = c("simpler_name_x" = "simpler_name")) %>%
  dplyr::rename(sector_x = sector) %>%
  left_join(asset_level_data, by = c("simpler_name_y" = "simpler_name")) %>%
  dplyr::rename(sector_y = sector)
#> # A tibble: 89,093 x 10
#>    simpler_name_x simpler_name_y score level id    name.x sector_x source name.y
#>    <chr>          <chr>          <dbl> <chr> <chr> <chr>  <chr>    <chr>  <chr> 
#>  1 astonmartin    astonmartin    1     ulti~ UP23  Aston~ automot~ loanb~ aston~
#>  2 astonmartin    avtozaz        0.681 ulti~ UP23  Aston~ automot~ loanb~ avtoz~
#>  3 astonmartin    bogdan         0.480 ulti~ UP23  Aston~ automot~ loanb~ bogdan
#>  4 astonmartin    chauto         0.591 ulti~ UP23  Aston~ automot~ loanb~ ch au~
#>  5 astonmartin    chehejia       0.311 ulti~ UP23  Aston~ automot~ loanb~ chehe~
#>  6 astonmartin    chtcauto       0.455 ulti~ UP23  Aston~ automot~ loanb~ chtc ~
#>  7 astonmartin    dongfenghonda  0.501 ulti~ UP23  Aston~ automot~ loanb~ dongf~
#>  8 astonmartin    dongfengluxgen 0.496 ulti~ UP23  Aston~ automot~ loanb~ dongf~
#>  9 astonmartin    electricmobil~ 0.456 ulti~ UP23  Aston~ automot~ loanb~ elect~
#> 10 astonmartin    faradayfuture  0.474 ulti~ UP23  Aston~ automot~ loanb~ farad~
#> # ... with 89,083 more rows, and 1 more variable: sector_y <chr>
```

You may pick rows at and above some score with `dplyr::fileter()`:

``` r
threshold <- 0.5
matched_by_sector %>%
  dplyr::filter(score >= threshold)
#> # A tibble: 35,683 x 3
#>    simpler_name_x simpler_name_y  score
#>    <chr>          <chr>           <dbl>
#>  1 astonmartin    astonmartin     1    
#>  2 astonmartin    avtozaz         0.681
#>  3 astonmartin    chauto          0.591
#>  4 astonmartin    dongfenghonda   0.501
#>  5 astonmartin    huanghaimotors  0.641
#>  6 astonmartin    jianghuaivw     0.576
#>  7 astonmartin    jianglingjingma 0.543
#>  8 astonmartin    jiangsujoylong  0.504
#>  9 astonmartin    jilintongtian   0.606
#> 10 astonmartin    master          0.677
#> # ... with 35,673 more rows
```

You may save the matched dataset with something like:

``` r
readr::write_csv(matched, "path/to/save/matches_to_be_verified.csv")
```

You should verify and edit the data manually, e.g. with MS Excel or
Google Sheets:

Compare `simpler_name_x` and `simpler_name_y` manually, along with the
loanbook sector. If you are happy with the match, set the `score` value
to `1` (only values of exactly `1` will be considered valid).

You may then re-read the validated data with:

``` r
readr::read_csv("path/to/load/verified_matches.csv")
```

**Work in progress, next step of analysis it to join in validated
matches in order of priority**.
