
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

Install the development version of r2dii.match from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("2DegreesInvesting/r2dii.match")
```

## Example

As usual, we start by using required packages. For general purpose
functions we’ll also use tidyverse.

``` r
library(r2dii.match)
library(r2dii.dataraw)
#> Loading required package: r2dii.utils
library(tidyverse)
#> -- Attaching packages ----------------------------------- tidyverse 1.3.0 --
#> <U+2713> ggplot2 3.2.1     <U+2713> purrr   0.3.3
#> <U+2713> tibble  2.1.3     <U+2713> dplyr   0.8.3
#> <U+2713> tidyr   1.0.0     <U+2713> stringr 1.4.0
#> <U+2713> readr   1.3.1     <U+2713> forcats 0.4.0
#> -- Conflicts -------------------------------------- tidyverse_conflicts() --
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
```

The following sections show the steps involved in the process.

### 1\. Create two datasets: [loanbook](https://2degreesinvesting.github.io/r2dii.dataraw/reference/loanbook_description.html) and [asset-level data (ald)](https://2degreesinvesting.github.io/r2dii.dataraw/reference/ald_description.html)

This step is up to you. You must structure your data like the example
datasets
[`loanbook_demo`](https://2degreesinvesting.github.io/r2dii.dataraw/reference/loanbook_demo.html)
and
[`ald_demo`](https://2degreesinvesting.github.io/r2dii.dataraw/reference/ald_demo.html)
(from the [r2dii.dataraw
package](https://2degreesinvesting.github.io/r2dii.dataraw)).

``` r
loanbook_demo
#> # A tibble: 320 x 19
#>    id_loan id_direct_loant… name_direct_loa… id_intermediate… name_intermedia…
#>    <chr>   <chr>            <chr>            <chr>            <chr>           
#>  1 L1      C294             Yuamen Xinneng … <NA>             <NA>            
#>  2 L2      C293             Yuamen Changyua… <NA>             <NA>            
#>  3 L3      C292             Yuama Ethanol L… IP5              Yuama Inc.      
#>  4 L4      C299             Yudaksel Holdin… <NA>             <NA>            
#>  5 L5      C305             Yukon Energy Co… <NA>             <NA>            
#>  6 L6      C304             Yukon Developme… <NA>             <NA>            
#>  7 L7      C227             Yaugoa-Zapadnay… <NA>             <NA>            
#>  8 L8      C303             Yueyang City Co… <NA>             <NA>            
#>  9 L9      C301             Yuedxiu Corp One IP10             Yuedxiu Group   
#> 10 L10     C302             Yuexi County AA… <NA>             <NA>            
#> # … with 310 more rows, and 14 more variables: id_ultimate_parent <chr>,
#> #   name_ultimate_parent <chr>, loan_size_outstanding <dbl>,
#> #   loan_size_outstanding_currency <chr>, loan_size_credit_limit <dbl>,
#> #   loan_size_credit_limit_currency <chr>, sector_classification_system <chr>,
#> #   sector_classification_input_type <chr>,
#> #   sector_classification_direct_loantaker <dbl>, fi_type <chr>,
#> #   flag_project_finance_loan <chr>, name_project <lgl>,
#> #   lei_direct_loantaker <lgl>, isin_direct_loantaker <lgl>

ald_demo
#> # A tibble: 17,368 x 13
#>    name_company sector technology production_unit  year production
#>    <chr>        <chr>  <chr>      <chr>           <dbl>      <dbl>
#>  1 aba hydropo… power  hydrocap   MW               2013    133340.
#>  2 aba hydropo… power  hydrocap   MW               2014    131582.
#>  3 aba hydropo… power  hydrocap   MW               2015    129824.
#>  4 aba hydropo… power  hydrocap   MW               2016    128065.
#>  5 aba hydropo… power  hydrocap   MW               2017    126307.
#>  6 aba hydropo… power  hydrocap   MW               2018    124549.
#>  7 aba hydropo… power  hydrocap   MW               2019    122790.
#>  8 aba hydropo… power  hydrocap   MW               2020    121032.
#>  9 aba hydropo… power  hydrocap   MW               2021    119274.
#> 10 aba hydropo… power  hydrocap   MW               2022    117515.
#> # … with 17,358 more rows, and 7 more variables: emission_factor <dbl>,
#> #   country_of_domicile <chr>, plant_location <chr>, number_of_assets <dbl>,
#> #   is_ultimate_owner <lgl>, is_ultimate_listed_owner <lgl>,
#> #   ald_timestamp <chr>
```

You may write *your-loanbook-template.csv* and *your-ald-template.csv*
with:

``` r
# Writting to current working directory 
loanbook_demo %>% 
  write_csv(path = "your-loanbook-template.csv")

ald_demo %>% 
  write_csv(path = "your-ald-template.csv")
```

You may then edit those files, save them as *your-loanbook.csv* and
*your-ald.csv*, and then read them back into R with:

``` r
# Reading from current working directory 
your_loanbook <- read_csv("your-loanbook.csv")
your_ald <- read_csv("your-ald.csv")
```

But here we’ll continue to use the `*_demo` datasets.

``` r
your_loanbook <- loanbook_demo
your_ald <- ald_demo
```

(If you are following this code, be sure to skip the code chunk above,
so it doesn’t overwrite `your_loanbook` and `your_ald` datasets.)

### 2\. Prepare each dataset for matching

`prepare_loanbook_for_matching()` does a lot of things. For example, it
adds the column `simpler_name`, a modified version of the `name` column
after applying best practices commonly used in name matching algorithms,
such as:

  - Remove special characters.
  - Replace language specific characters.
  - Abbreviate certain names to reduce their importance in the matching.
  - Spell out numbers to increase their importance.

<!-- end list -->

``` r
loanbook <- loanbook_demo %>% 
  prepare_loanbook_for_matching() %>% 
  # `simpler_name` and `name` move to the left, for clarity
  select(simpler_name, name, everything())
#> Warning: Uniquifying `id_direct_loantaker` & `id_ultimate_parent`.
#> Adding new columns `sector` and `borderline`.

loanbook
#> # A tibble: 638 x 6
#>    simpler_name          name                     level      id    sector source
#>    <chr>                 <chr>                    <chr>      <chr> <chr>  <chr> 
#>  1 yuamenxinnengthermal… Yuamen Xinneng Thermal … direct_lo… C294  power  loanb…
#>  2 alpineknitsindiapvt … Alpine Knits India Pvt.… ultimate_… UP15  power  loanb…
#>  3 yuamenchangyuanhydro… Yuamen Changyuan Hydrop… direct_lo… C293  power  loanb…
#>  4 ecowavepower          Eco Wave Power           ultimate_… UP84  power  loanb…
#>  5 yuamaethanol llc      Yuama Ethanol Llc        direct_lo… C292  power  loanb…
#>  6 universityofiowa      University Of Iowa       ultimate_… UP288 power  loanb…
#>  7 yudakselhldgs as      Yudaksel Holding A.S     direct_lo… C299  power  loanb…
#>  8 chinaelectricpowerfu… China Electric Power (F… ultimate_… UP54  power  loanb…
#>  9 yukonenergycorponese… Yukon Energy Corp 1736   direct_lo… C305  power  loanb…
#> 10 garlandpowerlight     Garland Power & Light    ultimate_… UP104 power  loanb…
#> # … with 628 more rows

ald <- ald_demo %>% 
  prepare_ald_for_matching() %>% 
  select(simpler_name, name, everything())

ald
#> # A tibble: 591 x 3
#>    simpler_name                  name                             sector  
#>    <chr>                         <chr>                            <chr>   
#>  1 abahydropowergenco ltd        aba hydropower generation co ltd power   
#>  2 achinskyglinoziemskijkombinat achinsky glinoziemskij kombinat  cement  
#>  3 affinityrenewables inc        affinity renewables inc.         power   
#>  4 africaoil corp                africa oil corp                  oil&gas 
#>  5 africonshp sa                 africon shipping sa              shipping
#>  6 agnisteelsprivate ltd         agni steels private limited      power   
#>  7 agrenewables                  agrenewables                     power   
#>  8 airasiaxbhd                   airasia x bhd                    aviation
#>  9 airbaltic                     airbaltic                        aviation
#> 10 airblue                       airblue                          aviation
#> # … with 581 more rows
```

### 3\. Score the goodness of the match between the loanbook and ald datasets

`match_by_simpler_name()` scores the similarity between `simpler_name`
values in the prepared loanbook and ald datasets.

``` r
match_by_simpler_name(loanbook, ald)
#> # A tibble: 833 x 10
#>    simpler_name_x simpler_name_y score name.x level id    sector_x source name.y
#>    <chr>          <chr>          <dbl> <chr>  <chr> <chr> <chr>    <chr>  <chr> 
#>  1 astonmartin    astonmartin    1     Aston… ulti… UP23  automot… loanb… aston…
#>  2 avtozaz        avtozaz        1     Avtoz… ulti… UP25  automot… loanb… avtoz…
#>  3 bogdan         bogdan         1     Bogdan ulti… UP36  automot… loanb… bogdan
#>  4 chauto         chauto         1     Ch Au… ulti… UP52  automot… loanb… ch au…
#>  5 chauto         chtcauto       0.867 Ch Au… ulti… UP52  automot… loanb… chtc …
#>  6 chehejia       chehejia       1     Chehe… ulti… UP53  automot… loanb… chehe…
#>  7 chtcauto       chauto         0.867 Chtc … ulti… UP58  automot… loanb… ch au…
#>  8 chtcauto       chtcauto       1     Chtc … ulti… UP58  automot… loanb… chtc …
#>  9 dongfenghonda  dongfenghonda  1     Dongf… ulti… UP80  automot… loanb… dongf…
#> 10 dongfenghonda  dongfengluxgen 0.867 Dongf… ulti… UP80  automot… loanb… dongf…
#> # … with 823 more rows, and 1 more variable: sector_y <chr>
```

By default, names are compared against ald names in the same sector
(i.e. `by_sector = TRUE`). Use `by_sector = FALSE` removes this
limitation, but it increases the matching run time on large datasets,
and the amount of nonsensical matches.

``` r
match_by_simpler_name(loanbook, ald, by_sector = FALSE)
#> # A tibble: 1,101 x 10
#>    simpler_name_x simpler_name_y score name.x level id    sector_x source name.y
#>    <chr>          <chr>          <dbl> <chr>  <chr> <chr> <chr>    <chr>  <chr> 
#>  1 abahydropower… abahydropower… 1     Aba H… ulti… UP1   power    loanb… aba h…
#>  2 achinskyglino… achinskyglino… 1     Achin… ulti… UP2   cement   loanb… achin…
#>  3 affinityrenew… affinityrenew… 1     Affin… ulti… UP3   power    loanb… affin…
#>  4 africaoil corp africaoil corp 1     Afric… dire… C2    oil and… loanb… afric…
#>  5 africaoil corp africonshp sa  0.812 Afric… dire… C2    oil and… loanb… afric…
#>  6 africonshp sa  africaoil corp 0.812 Afric… ulti… UP4   shipping loanb… afric…
#>  7 africonshp sa  africonshp sa  1     Afric… ulti… UP4   shipping loanb… afric…
#>  8 agnisteelspri… agnisteelspri… 1     Agni … ulti… UP5   power    loanb… agni …
#>  9 agrenewables   agrenewables   1     Agren… ulti… UP6   power    loanb… agren…
#> 10 airasiaxbhd    airasiaxbhd    1     Airas… dire… C3    aviation loanb… airas…
#> # … with 1,091 more rows, and 1 more variable: sector_y <chr>
```

`min_score` allows you to pick rows at and above some `score`.

``` r
matching_scores <- match_by_simpler_name(loanbook, ald, min_score = 0.9)

matching_scores
#> # A tibble: 438 x 10
#>    simpler_name_x simpler_name_y score name.x level id    sector_x source name.y
#>    <chr>          <chr>          <dbl> <chr>  <chr> <chr> <chr>    <chr>  <chr> 
#>  1 astonmartin    astonmartin        1 Aston… ulti… UP23  automot… loanb… aston…
#>  2 avtozaz        avtozaz            1 Avtoz… ulti… UP25  automot… loanb… avtoz…
#>  3 bogdan         bogdan             1 Bogdan ulti… UP36  automot… loanb… bogdan
#>  4 chauto         chauto             1 Ch Au… ulti… UP52  automot… loanb… ch au…
#>  5 chehejia       chehejia           1 Chehe… ulti… UP53  automot… loanb… chehe…
#>  6 chtcauto       chtcauto           1 Chtc … ulti… UP58  automot… loanb… chtc …
#>  7 dongfenghonda  dongfenghonda      1 Dongf… ulti… UP80  automot… loanb… dongf…
#>  8 dongfengluxgen dongfengluxgen     1 Dongf… ulti… UP79  automot… loanb… dongf…
#>  9 electricmobil… electricmobil…     1 Elect… ulti… UP89  automot… loanb… elect…
#> 10 faradayfuture  faradayfuture      1 Farad… ulti… UP94  automot… loanb… farad…
#> # … with 428 more rows, and 1 more variable: sector_y <chr>
```

### 3\. Write the output of the previous step into a .csv file

``` r
# Writting to current working directory 
matching_scores %>%
  write_csv("matching-scores.csv")
```

### 4\. Compare, edit, and save the data manually

  - Open *matching-scores.csv* with MS Excel, Google Sheets, or any
    spreadsheet editor.

  - Visually compare `simpler_name_x` and `simpler_name_y`, along with
    the loanbook sector.

  - Edit the data manually:
    
      - If you are happy with the match, set the `score` value to `1`.
      - Otherwise set or leave the `score` value to anything other than
        `1`.

  - Save the edited file as, say, *matching-scores-edited.csv*.

### 5\. Re-read the data from the previous step

``` r
# Reading from current working directory 
matching_scores %>%
  write_csv("matching-scores.csv")
```

### 6\. Join in validated matches in order of priority

TODO
