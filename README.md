
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
suppressPackageStartupMessages(
  library(tidyverse)
)
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

  - For each dataset, replace our demo data with your data.
  - Save each dataset as, say, *your\_loanbook.csv* and *your\_ald.csv*.
  - Read your datasets back into R with:

<!-- end list -->

``` r
# Reading from current working directory 
your_loanbook <- read_csv("your_loanbook.csv")
your_ald <- read_csv("your_ald.csv")
```

Here we’ll continue to use our `*_demo` datasets, pretending they
contain the data of your own.

``` r
# WARNING: Skip this to avoid overwriting your data with our demo data
your_loanbook <- loanbook_demo
your_ald <- ald_demo
```

### 2\. Score the goodness of the match between the loanbook and ald datasets

`match_name()` scores the match between names in a loanbook dataset
(lbk) and names in an asset-level dataset (ald). The names come from the
columns `name_direct_loantaker` and `name_ultimate_parent` of the
loanbook dataset, and from the column `name_company` of the a
asset-level dataset. The raw names are first transformed and stored in
the columns `alias` and `alias_ald`. Then the similarity between `alias`
and `alias_ald` is scored using `stringdist::stringsim()`. The process
to create the `alias_*` columns applies best-practices commonly used in
name matching algorithms, such as:

  - Remove special characters.
  - Replace language specific characters.
  - Abbreviate certain names to reduce their importance in the matching.
  - Spell out numbers to increase their importance.

<!-- end list -->

``` r
match_name(your_loanbook, your_ald)
#> # A tibble: 1,350 x 26
#>    id_loan id_direct_loant… id_intermediate… id_ultimate_par… loan_size_outst…
#>    <chr>   <chr>            <chr>            <chr>                       <dbl>
#>  1 <NA>    <NA>             <NA>             <NA>                           NA
#>  2 <NA>    <NA>             <NA>             <NA>                           NA
#>  3 <NA>    <NA>             <NA>             <NA>                           NA
#>  4 <NA>    <NA>             <NA>             <NA>                           NA
#>  5 <NA>    <NA>             <NA>             <NA>                           NA
#>  6 <NA>    <NA>             <NA>             <NA>                           NA
#>  7 <NA>    <NA>             <NA>             <NA>                           NA
#>  8 <NA>    <NA>             <NA>             <NA>                           NA
#>  9 <NA>    <NA>             <NA>             <NA>                           NA
#> 10 <NA>    <NA>             <NA>             <NA>                           NA
#> # … with 1,340 more rows, and 21 more variables:
#> #   loan_size_outstanding_currency <chr>, loan_size_credit_limit <dbl>,
#> #   loan_size_credit_limit_currency <chr>, sector_classification_system <chr>,
#> #   sector_classification_input_type <chr>,
#> #   sector_classification_direct_loantaker <dbl>, fi_type <chr>,
#> #   flag_project_finance_loan <chr>, name_project <lgl>,
#> #   lei_direct_loantaker <lgl>, isin_direct_loantaker <lgl>, id <chr>,
#> #   level <chr>, sector <chr>, sector_ald <chr>, name <chr>, name_ald <chr>,
#> #   alias <chr>, alias_ald <chr>, score <dbl>, source <chr>
```

`match_name()` defaults to scoring matches between `alias_*` strings
that belong to the same sector. Using `by_sector = FALSE` removes this
limitation – increasing computation time, and the number of matches with
a low score.

``` r
match_name(your_loanbook, your_ald, by_sector = FALSE) %>% 
  nrow()
#> [1] 1974

# Compare
match_name(your_loanbook, your_ald, by_sector = TRUE) %>% 
  nrow()
#> [1] 1350
```

`min_score` allows you to pick rows of a minimum `score` and above.

``` r
matched <- match_name(your_loanbook, your_ald, min_score = 0.9)
range(matched$score)
#> [1] 0.9058824 1.0000000
```

### 3\. Write the output of the previous step into a .csv file

Write the output of the previous step into a .csv file with:

``` r
# Writting to current working directory 
matched %>%
  write_csv("matched.csv")
```

### 4\. Compare, edit, and save the data manually

  - Open *matched.csv* with any spreadsheet editor (e.g. MS Excel,
    Google Sheets).

  - Visually compare `alias` and `alias_ald`, along with the loanbook
    sector.

  - Edit the data manually:
    
      - If you are happy with the match, set the `score` value to `1`.
      - Otherwise set or leave the `score` value to anything other than
        `1`.

  - Save the edited file as, say, *matched\_edited.csv*.

### 5\. Re-read the data from the previous step

Re-read the data from the previous step with:

``` r
# Reading from current working directory 
matched <- read_csv("matched_edited.csv")
```

### 6\. Pick validated matches and prioritize by level

The `matched` dataset may have multiple matches per loan. To get the
best match only, use `priorityze()` – it picks rows where `score` is 1
and `level` per loan is of highest `priority()`.

``` r
some_interesting_columns <- vars(id, level, starts_with("alias"), score)

matched %>% 
  prioritize() %>% 
  select(!!! some_interesting_columns)
#> # A tibble: 402 x 5
#>    id    level            alias                    alias_ald               score
#>    <chr> <chr>            <chr>                    <chr>                   <dbl>
#>  1 UP23  direct_loantaker astonmartin              astonmartin                 1
#>  2 UP25  direct_loantaker avtozaz                  avtozaz                     1
#>  3 UP36  direct_loantaker bogdan                   bogdan                      1
#>  4 UP52  direct_loantaker chauto                   chauto                      1
#>  5 UP53  direct_loantaker chehejia                 chehejia                    1
#>  6 UP58  direct_loantaker chtcauto                 chtcauto                    1
#>  7 UP80  direct_loantaker dongfenghonda            dongfenghonda               1
#>  8 UP79  direct_loantaker dongfengluxgen           dongfengluxgen              1
#>  9 UP89  direct_loantaker electricmobilitysolutio… electricmobilitysoluti…     1
#> 10 UP94  direct_loantaker faradayfuture            faradayfuture               1
#> # … with 392 more rows
```

The default priority is set internally via `prioritize_levels()`.

``` r
prioritize_level(matched)
#> [1] "direct_loantaker"      "intermediate_parent_1" "ultimate_parent"
```

You may use a different priority. One way to do that is to pass a
function to `priority`. For example, use `rev` to reverse the default
priority.

``` r
matched %>% 
  prioritize(priority = rev) %>% 
  select(!!! some_interesting_columns)
#> # A tibble: 402 x 5
#>    id    level           alias                    alias_ald                score
#>    <chr> <chr>           <chr>                    <chr>                    <dbl>
#>  1 UP23  ultimate_parent astonmartin              astonmartin                  1
#>  2 UP25  ultimate_parent avtozaz                  avtozaz                      1
#>  3 UP36  ultimate_parent bogdan                   bogdan                       1
#>  4 UP52  ultimate_parent chauto                   chauto                       1
#>  5 UP53  ultimate_parent chehejia                 chehejia                     1
#>  6 UP58  ultimate_parent chtcauto                 chtcauto                     1
#>  7 UP80  ultimate_parent dongfenghonda            dongfenghonda                1
#>  8 UP79  ultimate_parent dongfengluxgen           dongfengluxgen               1
#>  9 UP89  ultimate_parent electricmobilitysolutio… electricmobilitysolutio…     1
#> 10 UP94  ultimate_parent faradayfuture            faradayfuture                1
#> # … with 392 more rows
```

You may also pass a character vector with a custom priority – which you
may write explicitly or with the help of `select_chr()`.

``` r
bad_idea <- select_chr(
  matched$level,
  matches("intermediate"),
  everything()
)

bad_idea
#> [1] "intermediate_parent_1" "ultimate_parent"       "direct_loantaker"

matched %>% 
  prioritize(priority = bad_idea) %>% 
  select(!!! some_interesting_columns)
#> # A tibble: 402 x 5
#>    id    level               alias                  alias_ald              score
#>    <chr> <chr>               <chr>                  <chr>                  <dbl>
#>  1 UP23  intermediate_paren… astonmartin            astonmartin                1
#>  2 UP25  intermediate_paren… avtozaz                avtozaz                    1
#>  3 UP36  intermediate_paren… bogdan                 bogdan                     1
#>  4 UP52  intermediate_paren… chauto                 chauto                     1
#>  5 UP53  intermediate_paren… chehejia               chehejia                   1
#>  6 UP58  intermediate_paren… chtcauto               chtcauto                   1
#>  7 UP80  intermediate_paren… dongfenghonda          dongfenghonda              1
#>  8 UP79  intermediate_paren… dongfengluxgen         dongfengluxgen             1
#>  9 UP89  intermediate_paren… electricmobilitysolut… electricmobilitysolut…     1
#> 10 UP94  intermediate_paren… faradayfuture          faradayfuture              1
#> # … with 392 more rows
```
