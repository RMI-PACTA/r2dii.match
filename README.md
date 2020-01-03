
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
the columns `alias_lbk` and `alias_ald`. Then the similarity between
`alias_lbk` and `alias_ald` is scored using `stringdist::stringsim()`.
The process to create the `alias_*` columns applies best-practices
commonly used in name matching algorithms, such as:

  - Remove special characters.
  - Replace language specific characters.
  - Abbreviate certain names to reduce their importance in the matching.
  - Spell out numbers to increase their importance.

<!-- end list -->

``` r
match_name(your_loanbook, your_ald)
#> # A tibble: 1,350 x 26
#>    alias_lbk alias_ald score id_lbk sector_lbk source_lbk name_ald sector_ald
#>    <chr>     <chr>     <dbl> <chr>  <chr>      <chr>      <chr>    <chr>     
#>  1 astonmar… astonmar…     1 UP23   automotive loanbook   aston m… automotive
#>  2 astonmar… astonmar…     1 UP23   automotive loanbook   aston m… automotive
#>  3 astonmar… astonmar…     1 UP23   automotive loanbook   aston m… automotive
#>  4 avtozaz   avtozaz       1 UP25   automotive loanbook   avtozaz  automotive
#>  5 avtozaz   avtozaz       1 UP25   automotive loanbook   avtozaz  automotive
#>  6 avtozaz   avtozaz       1 UP25   automotive loanbook   avtozaz  automotive
#>  7 bogdan    bogdan        1 UP36   automotive loanbook   bogdan   automotive
#>  8 bogdan    bogdan        1 UP36   automotive loanbook   bogdan   automotive
#>  9 bogdan    bogdan        1 UP36   automotive loanbook   bogdan   automotive
#> 10 chauto    chauto        1 UP52   automotive loanbook   ch auto  automotive
#> # … with 1,340 more rows, and 18 more variables: id_loan_lbk <chr>,
#> #   id_direct_loantaker_lbk <chr>, id_intermediate_parent_1_lbk <chr>,
#> #   id_ultimate_parent_lbk <chr>, loan_size_outstanding_lbk <dbl>,
#> #   loan_size_outstanding_currency_lbk <chr>, loan_size_credit_limit_lbk <dbl>,
#> #   loan_size_credit_limit_currency_lbk <chr>,
#> #   sector_classification_system_lbk <chr>,
#> #   sector_classification_input_type_lbk <chr>,
#> #   sector_classification_direct_loantaker_lbk <dbl>, fi_type_lbk <chr>,
#> #   flag_project_finance_loan_lbk <chr>, name_project_lbk <lgl>,
#> #   lei_direct_loantaker_lbk <lgl>, isin_direct_loantaker_lbk <lgl>,
#> #   level_lbk <chr>, name_lbk <chr>
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

  - Visually compare `alias_lbk` and `alias_ald`, along with the
    loanbook sector.

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

Pick validated matches, i.e. those with a `score` of 1.

``` r
validated <- matched %>% 
  filter(score == 1L)
```

Here is an interesting view of the validated data.

``` r
some_interesting_columns <- vars(id_lbk, level_lbk, starts_with("alias"), score)

validated %>% 
  select(!!! some_interesting_columns)
#> # A tibble: 1,269 x 5
#>    id_lbk level_lbk             alias_lbk   alias_ald   score
#>    <chr>  <chr>                 <chr>       <chr>       <dbl>
#>  1 UP23   ultimate_parent       astonmartin astonmartin     1
#>  2 UP23   direct_loantaker      astonmartin astonmartin     1
#>  3 UP23   intermediate_parent_1 astonmartin astonmartin     1
#>  4 UP25   ultimate_parent       avtozaz     avtozaz         1
#>  5 UP25   direct_loantaker      avtozaz     avtozaz         1
#>  6 UP25   intermediate_parent_1 avtozaz     avtozaz         1
#>  7 UP36   ultimate_parent       bogdan      bogdan          1
#>  8 UP36   direct_loantaker      bogdan      bogdan          1
#>  9 UP36   intermediate_parent_1 bogdan      bogdan          1
#> 10 UP52   ultimate_parent       chauto      chauto          1
#> # … with 1,259 more rows
```

For each `id_lbk` there may be matches at multiple levels. To get only
the best match, we set a priority for all possible levels, and we use it
to pick one row per id.

``` r
sorted_levels <- sort(unique(matched$level_lbk))
sorted_levels
#> [1] "direct_loantaker"      "intermediate_parent_1" "ultimate_parent"

prioritized_levels <- sorted_levels %>% 
  select_chr(
    # Showing off different tidyselect helpers
    starts_with("direct"), 
    matches("intermediate"), 
    contains("ultimate"), 
    everything()
  )
prioritized_levels
#> [1] "direct_loantaker"      "intermediate_parent_1" "ultimate_parent"

prioritized <- matched %>% 
  group_by(id_lbk) %>% 
  prioritize_at("level_lbk", priority = prioritized_levels) %>% 
  ungroup()
```

Here is an interesting view of the prioritized data.

``` r
prioritized %>% 
  select(!!! some_interesting_columns)
#> # A tibble: 403 x 5
#>    id_lbk level_lbk        alias_lbk               alias_ald               score
#>    <chr>  <chr>            <chr>                   <chr>                   <dbl>
#>  1 UP23   direct_loantaker astonmartin             astonmartin                 1
#>  2 UP25   direct_loantaker avtozaz                 avtozaz                     1
#>  3 UP36   direct_loantaker bogdan                  bogdan                      1
#>  4 UP52   direct_loantaker chauto                  chauto                      1
#>  5 UP53   direct_loantaker chehejia                chehejia                    1
#>  6 UP58   direct_loantaker chtcauto                chtcauto                    1
#>  7 UP80   direct_loantaker dongfenghonda           dongfenghonda               1
#>  8 UP79   direct_loantaker dongfengluxgen          dongfengluxgen              1
#>  9 UP89   direct_loantaker electricmobilitysoluti… electricmobilitysoluti…     1
#> 10 UP94   direct_loantaker faradayfuture           faradayfuture               1
#> # … with 393 more rows
```

You may prioritize levels however you like.

``` r
reverse_priority <- rev(prioritized_levels)
reverse_priority
#> [1] "ultimate_parent"       "intermediate_parent_1" "direct_loantaker"

matched %>% 
  group_by(id_lbk) %>% 
  prioritize_at("level_lbk", priority = reverse_priority) %>% 
  ungroup() %>% 
  select(!!! some_interesting_columns)
#> # A tibble: 403 x 5
#>    id_lbk level_lbk       alias_lbk                alias_ald               score
#>    <chr>  <chr>           <chr>                    <chr>                   <dbl>
#>  1 UP23   ultimate_parent astonmartin              astonmartin                 1
#>  2 UP25   ultimate_parent avtozaz                  avtozaz                     1
#>  3 UP36   ultimate_parent bogdan                   bogdan                      1
#>  4 UP52   ultimate_parent chauto                   chauto                      1
#>  5 UP53   ultimate_parent chehejia                 chehejia                    1
#>  6 UP58   ultimate_parent chtcauto                 chtcauto                    1
#>  7 UP80   ultimate_parent dongfenghonda            dongfenghonda               1
#>  8 UP79   ultimate_parent dongfengluxgen           dongfengluxgen              1
#>  9 UP89   ultimate_parent electricmobilitysolutio… electricmobilitysoluti…     1
#> 10 UP94   ultimate_parent faradayfuture            faradayfuture               1
#> # … with 393 more rows
```
