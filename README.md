
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

We’ll use required packages from r2dii, and some convenient packages
from the tidyverse.

``` r
library(r2dii.match)
library(r2dii.dataraw)
#> Loading required package: r2dii.utils
library(tidyverse)
#> -- Attaching packages ---------------------------------- tidyverse 1.3.0 --
#> <U+2713> ggplot2 3.2.1     <U+2713> purrr   0.3.3
#> <U+2713> tibble  2.1.3     <U+2713> dplyr   0.8.3
#> <U+2713> tidyr   1.0.0     <U+2713> stringr 1.4.0
#> <U+2713> readr   1.3.1     <U+2713> forcats 0.4.0
#> -- Conflicts ------------------------------------- tidyverse_conflicts() --
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
```

The process for matching loanbook and ald datasets has multiple steps:

### 1\. Create two datasets: [loanbook](https://2degreesinvesting.github.io/r2dii.dataraw/reference/loanbook_description.html) and [asset-level data (ald)](https://2degreesinvesting.github.io/r2dii.dataraw/reference/ald_description.html)

Start by creating datasets like
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

You may use these datasets as a template:

  - Write *loanbook\_demo.csv* and *ald\_demo.csv* with:

<!-- end list -->

``` r
# Writting to current working directory 
loanbook_demo %>% 
  write_csv(path = "loanbook_demo.csv")

ald_demo %>% 
  write_csv(path = "ald_demo.csv")
```

  - In each dataset, replace our demo data with your data.

  - Save save each dataset as, say, *your\_loanbook.csv* and
    *your\_ald.csv*.

  - Read your datasets back into R with:

<!-- end list -->

``` r
# Reading from current working directory 
your_loanbook <- read_csv("your_loanbook.csv")
your_ald <- read_csv("your_ald.csv")
```

Here we’ll continue to use the `*_demo` datasets.

``` r
warning("Skip this chunk to avoid overwriting your data with our demo data.")
#> Warning: Skip this chunk to avoid overwriting your data with our demo data.

your_loanbook <- loanbook_demo
your_ald <- ald_demo
```

### 2\. Score the goodness of the match between the loanbook and ald datasets

`match_name()` scores the match between names in a loanbook dataset
(lbk; columns `name_direct_loantaker` and `name_ultimate_parent`) with
names in an asset-level dataset (ald; column `name_company`). The raw
names are first transformed and stored in the columns `alias_lbk` and
`alias_ald`, then the similarity between them is scored using
`stringdist::stringsim()`.

The process to create the `alias_*` columns applies best-practices
commonly used in name matching algorithms, such as:

  - Remove special characters.
  - Replace language specific characters.
  - Abbreviate certain names to reduce their importance in the matching.
  - Spell out numbers to increase their importance.

<!-- end list -->

``` r
match_name(your_loanbook, your_ald)
#> # A tibble: 450 x 27
#>    alias_lbk alias_ald score id_lbk sector_lbk source_lbk name_ald sector_ald
#>    <chr>     <chr>     <dbl> <chr>  <chr>      <chr>      <chr>    <chr>     
#>  1 astonmar… astonmar…     1 UP23   automotive loanbook   aston m… automotive
#>  2 avtozaz   avtozaz       1 UP25   automotive loanbook   avtozaz  automotive
#>  3 bogdan    bogdan        1 UP36   automotive loanbook   bogdan   automotive
#>  4 chauto    chauto        1 UP52   automotive loanbook   ch auto  automotive
#>  5 chehejia  chehejia      1 UP53   automotive loanbook   chehejia automotive
#>  6 chtcauto  chtcauto      1 UP58   automotive loanbook   chtc au… automotive
#>  7 dongfeng… dongfeng…     1 UP80   automotive loanbook   dongfen… automotive
#>  8 dongfeng… dongfeng…     1 UP79   automotive loanbook   dongfen… automotive
#>  9 electric… electric…     1 UP89   automotive loanbook   electri… automotive
#> 10 faradayf… faradayf…     1 UP94   automotive loanbook   faraday… automotive
#> # … with 440 more rows, and 19 more variables: name_ultimate_parent_lbk <chr>,
#> #   name_direct_loantaker_lbk <chr>, id_loan_lbk <chr>,
#> #   id_direct_loantaker_lbk <chr>, id_intermediate_parent_1_lbk <chr>,
#> #   name_intermediate_parent_1_lbk <chr>, id_ultimate_parent_lbk <chr>,
#> #   loan_size_outstanding_lbk <dbl>, loan_size_outstanding_currency_lbk <chr>,
#> #   loan_size_credit_limit_lbk <dbl>,
#> #   loan_size_credit_limit_currency_lbk <chr>,
#> #   sector_classification_system_lbk <chr>,
#> #   sector_classification_input_type_lbk <chr>,
#> #   sector_classification_direct_loantaker_lbk <dbl>, fi_type_lbk <chr>,
#> #   flag_project_finance_loan_lbk <chr>, name_project_lbk <lgl>,
#> #   lei_direct_loantaker_lbk <lgl>, isin_direct_loantaker_lbk <lgl>
```

By default, `alias_lbk` and `alias_ald` are scored only by sector.
`by_sector = FALSE` removes this limitation, increasing computation
time, and the number of nonsensical matches.

``` r
match_name(your_loanbook, your_ald, by_sector = FALSE)
#> # A tibble: 658 x 27
#>    alias_lbk alias_ald score id_lbk sector_lbk source_lbk name_ald sector_ald
#>    <chr>     <chr>     <dbl> <chr>  <chr>      <chr>      <chr>    <chr>     
#>  1 abahydro… abahydro…     1 UP1    power      loanbook   aba hyd… power     
#>  2 achinsky… achinsky…     1 UP2    cement     loanbook   achinsk… cement    
#>  3 affinity… affinity…     1 UP3    power      loanbook   affinit… power     
#>  4 africaoi… africaoi…     1 C2     oil and g… loanbook   africa … oil&gas   
#>  5 africons… africons…     1 UP4    shipping   loanbook   africon… shipping  
#>  6 agnistee… agnistee…     1 UP5    power      loanbook   agni st… power     
#>  7 agrenewa… agrenewa…     1 UP6    power      loanbook   agrenew… power     
#>  8 airasiax… airasiax…     1 C3     aviation   loanbook   airasia… aviation  
#>  9 airasiax… airasiax…     1 UP7    aviation   loanbook   airasia… aviation  
#> 10 airbaltic airbaltic     1 C4     aviation   loanbook   airbalt… aviation  
#> # … with 648 more rows, and 19 more variables: name_ultimate_parent_lbk <chr>,
#> #   name_direct_loantaker_lbk <chr>, id_loan_lbk <chr>,
#> #   id_direct_loantaker_lbk <chr>, id_intermediate_parent_1_lbk <chr>,
#> #   name_intermediate_parent_1_lbk <chr>, id_ultimate_parent_lbk <chr>,
#> #   loan_size_outstanding_lbk <dbl>, loan_size_outstanding_currency_lbk <chr>,
#> #   loan_size_credit_limit_lbk <dbl>,
#> #   loan_size_credit_limit_currency_lbk <chr>,
#> #   sector_classification_system_lbk <chr>,
#> #   sector_classification_input_type_lbk <chr>,
#> #   sector_classification_direct_loantaker_lbk <dbl>, fi_type_lbk <chr>,
#> #   flag_project_finance_loan_lbk <chr>, name_project_lbk <lgl>,
#> #   lei_direct_loantaker_lbk <lgl>, isin_direct_loantaker_lbk <lgl>
```

`min_score` allows you to pick rows of a minimum `score` and above.

``` r
matching_scores <- match_name(your_loanbook, your_ald, min_score = 0.9)

matching_scores
#> # A tibble: 424 x 27
#>    alias_lbk alias_ald score id_lbk sector_lbk source_lbk name_ald sector_ald
#>    <chr>     <chr>     <dbl> <chr>  <chr>      <chr>      <chr>    <chr>     
#>  1 astonmar… astonmar…     1 UP23   automotive loanbook   aston m… automotive
#>  2 avtozaz   avtozaz       1 UP25   automotive loanbook   avtozaz  automotive
#>  3 bogdan    bogdan        1 UP36   automotive loanbook   bogdan   automotive
#>  4 chauto    chauto        1 UP52   automotive loanbook   ch auto  automotive
#>  5 chehejia  chehejia      1 UP53   automotive loanbook   chehejia automotive
#>  6 chtcauto  chtcauto      1 UP58   automotive loanbook   chtc au… automotive
#>  7 dongfeng… dongfeng…     1 UP80   automotive loanbook   dongfen… automotive
#>  8 dongfeng… dongfeng…     1 UP79   automotive loanbook   dongfen… automotive
#>  9 electric… electric…     1 UP89   automotive loanbook   electri… automotive
#> 10 faradayf… faradayf…     1 UP94   automotive loanbook   faraday… automotive
#> # … with 414 more rows, and 19 more variables: name_ultimate_parent_lbk <chr>,
#> #   name_direct_loantaker_lbk <chr>, id_loan_lbk <chr>,
#> #   id_direct_loantaker_lbk <chr>, id_intermediate_parent_1_lbk <chr>,
#> #   name_intermediate_parent_1_lbk <chr>, id_ultimate_parent_lbk <chr>,
#> #   loan_size_outstanding_lbk <dbl>, loan_size_outstanding_currency_lbk <chr>,
#> #   loan_size_credit_limit_lbk <dbl>,
#> #   loan_size_credit_limit_currency_lbk <chr>,
#> #   sector_classification_system_lbk <chr>,
#> #   sector_classification_input_type_lbk <chr>,
#> #   sector_classification_direct_loantaker_lbk <dbl>, fi_type_lbk <chr>,
#> #   flag_project_finance_loan_lbk <chr>, name_project_lbk <lgl>,
#> #   lei_direct_loantaker_lbk <lgl>, isin_direct_loantaker_lbk <lgl>
```

### 3\. Write the output of the previous step into a .csv file

Write the output of the previous step into a .csv file with:

``` r
# Writting to current working directory 
matching_scores %>%
  write_csv("matching_scores.csv")
```

### 4\. Compare, edit, and save the data manually

  - Open *matching\_scores.csv* with any spreadsheet editor (e.g. MS
    Excel, Google Sheets).

  - Visually compare `alias_lbk` and `alias_ald`, along with the
    loanbook sector.

  - Edit the data manually:
    
      - If you are happy with the match, set the `score` value to `1`.
      - Otherwise set or leave the `score` value to anything other than
        `1`.

  - Save the edited file as, say, *matching\_scores\_edited.csv*.

### 5\. Re-read the data from the previous step

Re-read the data from the previous step with:

``` r
# Reading from current working directory 
matching_scores %>%
  write_csv("matching_scores_edited.csv")
```

### 6\. Join in validated matches in order of priority

TODO
