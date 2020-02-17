
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

The goal of r2dii.match is to match generic loanbook data with physical
asset level data (ald).

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
asset-level dataset. The raw names are internally transformed applying
best-practices commonly used in name matching algorithms, such as:

  - Remove special characters.
  - Replace language specific characters.
  - Abbreviate certain names to reduce their importance in the matching.
  - Spell out numbers to increase their importance.

Then, the similarity is scored between the internally-transformed names
from the loanbook versus ald datasets. The scoring algorithm is
`stringdist::stringsim()`.

``` r
match_name(your_loanbook, your_ald)
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

`match_name()` defaults to scoring matches between name strings that
belong to the same sector. Using `by_sector = FALSE` removes this
limitation – increasing computation time, and the number of matches with
a low score.

``` r
match_name(your_loanbook, your_ald, by_sector = FALSE) %>% 
  nrow()
#> [1] 673

# Compare
match_name(your_loanbook, your_ald, by_sector = TRUE) %>% 
  nrow()
#> [1] 502
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

  - Visually compare names from loanbook versus ald datasets, along with
    the loanbook sector.

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
some_interesting_columns <- vars(id_2dii, level, score)

matched %>% 
  prioritize() %>% 
  select(!!! some_interesting_columns)
#> # A tibble: 267 x 3
#>    id_2dii level            score
#>    <chr>   <chr>            <dbl>
#>  1 DL167   direct_loantaker     1
#>  2 DL168   direct_loantaker     1
#>  3 DL169   direct_loantaker     1
#>  4 DL170   direct_loantaker     1
#>  5 DL172   direct_loantaker     1
#>  6 DL175   direct_loantaker     1
#>  7 DL177   direct_loantaker     1
#>  8 DL179   direct_loantaker     1
#>  9 DL181   direct_loantaker     1
#> 10 DL183   direct_loantaker     1
#> # … with 257 more rows
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
#> # A tibble: 267 x 3
#>    id_2dii level           score
#>    <chr>   <chr>           <dbl>
#>  1 UP23    ultimate_parent     1
#>  2 UP25    ultimate_parent     1
#>  3 UP36    ultimate_parent     1
#>  4 UP52    ultimate_parent     1
#>  5 UP53    ultimate_parent     1
#>  6 UP58    ultimate_parent     1
#>  7 UP79    ultimate_parent     1
#>  8 UP80    ultimate_parent     1
#>  9 UP89    ultimate_parent     1
#> 10 UP94    ultimate_parent     1
#> # … with 257 more rows
```
