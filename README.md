
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://i.imgur.com/3jITMq8.png" align="right" height=40 /> Match loanbook with asset level data

<!-- badges: start -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/r2dii.match)](https://CRAN.R-project.org/package=r2dii.match)
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

This example aims to show the entire matching process. As usual, we
start by using required packages. For convenience we’ll also use the
tidyverse.

``` r
library(r2dii.match)
library(r2dii.dataraw)
#> Loading required package: r2dii.utils
library(tidyverse)
#> -- Attaching packages -------------------------------------------- tidyverse 1.3.0 --
#> v ggplot2 3.2.1     v purrr   0.3.3
#> v tibble  2.1.3     v dplyr   0.8.3
#> v tidyr   1.0.0     v stringr 1.4.0
#> v readr   1.3.1     v forcats 0.4.0
#> -- Conflicts ----------------------------------------------- tidyverse_conflicts() --
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
prepared. To this end, there are several mandatory steps, and several
optional steps.

We can bridge from multiple sector classification codes to 2Dii’s
sectors: automotive, aviation, cement, oil and gas, power, shipping,
steel.

``` r
loanbook_demo %>%
  bridge_sector() %>%
  # Focusing on columns related to sector
  select(
    sector_classification_system,
    sector_classification_input_type,
    sector_classification_direct_loantaker,
    sector,
    borderline
  )
#> # A tibble: 320 x 5
#>    sector_classificat~ sector_classificat~ sector_classificat~ sector borderline
#>    <chr>               <chr>                             <dbl> <chr>  <chr>     
#>  1 NACE                Code                               3511 power  TRUE      
#>  2 NACE                Code                               3511 power  TRUE      
#>  3 NACE                Code                               3511 power  TRUE      
#>  4 NACE                Code                               3511 power  TRUE      
#>  5 NACE                Code                               3511 power  TRUE      
#>  6 NACE                Code                               3511 power  TRUE      
#>  7 NACE                Code                               3511 power  TRUE      
#>  8 NACE                Code                               3511 power  TRUE      
#>  9 NACE                Code                               3511 power  TRUE      
#> 10 NACE                Code                               3511 power  TRUE      
#> # ... with 310 more rows
```

In case the loanbook has non-unique IDs, can generate name+sector
specific IDs (this is especially important if one company is classified
in two sectors for two loans).

``` r
loanbook_demo %>%
  id_by_loantaker_sector()
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

Before we run the fuzzy matching algorithm, we simplify the loanbook and
ald names using:

``` r
some_customer_names <- c("3M Company", "Abbott Laboratories", "AbbVie Inc.")
replace_customer_name(some_customer_names)
#> [1] "threem co"          "abbottlaboratories" "abbvie inc"

# replacements can be defined from scratch using:
custom_replacement <- tibble(from = "AAAA", to = "B")
replace_customer_name("Aa Aaaa", from_to = custom_replacement)
#> [1] "aab"

# or appended to the existing list of replacements:
get_replacements()
#> # A tibble: 61 x 2
#>    from    to   
#>    <chr>   <chr>
#>  1 " and " " & "
#>  2 " en "  " & "
#>  3 " och " " & "
#>  4 " und " " & "
#>  5 (pjsc)  ""   
#>  6 (pte)   ""   
#>  7 (pvt)   ""   
#>  8 0       null 
#>  9 1       one  
#> 10 2       two  
#> # ... with 51 more rows

appended_replacements <- get_replacements() %>%
  add_row(
    .before = 1,
    from = c("AA", "BB"), to = c("alpha", "beta")
  )
appended_replacements
#> # A tibble: 63 x 2
#>    from    to   
#>    <chr>   <chr>
#>  1 AA      alpha
#>  2 BB      beta 
#>  3 " and " " & "
#>  4 " en "  " & "
#>  5 " och " " & "
#>  6 " und " " & "
#>  7 (pjsc)  ""   
#>  8 (pte)   ""   
#>  9 (pvt)   ""   
#> 10 0       null 
#> # ... with 53 more rows

# And in combination with `replace_customer_name()`
replace_customer_name(c("AA", "BB", "1"), from_to = appended_replacements)
#> [1] "alpha" "beta"  "one"
```

The following function takes a loanbook with non-corrupt IDs and outputs
a list of all unique name and sector combinations at every level,
including the simplified name, to be used in the matching process:

``` r
prep_loanbook <- loanbook_demo %>%
  id_by_loantaker_sector() %>%
  prepare_loanbook_for_matching()

prep_loanbook
#> # A tibble: 638 x 6
#>    level      id    name                     sector source  simpler_name        
#>    <chr>      <chr> <chr>                    <chr>  <chr>   <chr>               
#>  1 direct_lo~ C294  Yuamen Xinneng Thermal ~ power  loanbo~ yuamenxinnengtherma~
#>  2 ultimate_~ UP15  Alpine Knits India Pvt.~ power  loanbo~ alpineknitsindiapvt~
#>  3 direct_lo~ C293  Yuamen Changyuan Hydrop~ power  loanbo~ yuamenchangyuanhydr~
#>  4 ultimate_~ UP84  Eco Wave Power           power  loanbo~ ecowavepower        
#>  5 direct_lo~ C292  Yuama Ethanol Llc        power  loanbo~ yuamaethanol llc    
#>  6 ultimate_~ UP288 University Of Iowa       power  loanbo~ universityofiowa    
#>  7 direct_lo~ C299  Yudaksel Holding A.S     power  loanbo~ yudakselhldgs as    
#>  8 ultimate_~ UP54  China Electric Power (F~ power  loanbo~ chinaelectricpowerf~
#>  9 direct_lo~ C305  Yukon Energy Corp 1736   power  loanbo~ yukonenergycorpones~
#> 10 ultimate_~ UP104 Garland Power & Light    power  loanbo~ garlandpowerlight   
#> # ... with 628 more rows
```

And similarly for the ald:

``` r
prep_ald <- r2dii.dataraw::ald_demo %>%
  prepare_ald_for_matching()

prep_ald
#> # A tibble: 591 x 3
#>    name                             sector   simpler_name                 
#>    <chr>                            <chr>    <chr>                        
#>  1 aba hydropower generation co ltd power    abahydropowergenco ltd       
#>  2 achinsky glinoziemskij kombinat  cement   achinskyglinoziemskijkombinat
#>  3 affinity renewables inc.         power    affinityrenewables inc       
#>  4 africa oil corp                  oil&gas  africaoil corp               
#>  5 africon shipping sa              shipping africonshp sa                
#>  6 agni steels private limited      power    agnisteelsprivate ltd        
#>  7 agrenewables                     power    agrenewables                 
#>  8 airasia x bhd                    aviation airasiaxbhd                  
#>  9 airbaltic                        aviation airbaltic                    
#> 10 airblue                          aviation airblue                      
#> # ... with 581 more rows
```

For the purpose of manual matching, you can substitute the name and/ or
sector of particular loans at the desired level when preparing the
loanbook data. To do so, specify the `overwrite` argument in
prepare\_loanbook\_for\_matching(). (To substitute only the name, leave
sector as `NA` and vice-versa).

``` r
overwrite_demo <- r2dii.dataraw::overwrite_demo
overwrite_demo
#> # A tibble: 2 x 5
#>   level            id    name                 sector source
#>   <chr>            <chr> <chr>                <chr>  <chr> 
#> 1 direct_loantaker C294  yuamen power company coal   manual
#> 2 ultimate_parent  UP15  alpine india         power  manual

prep_loanbook <- loanbook_demo %>%
  id_by_loantaker_sector() %>%
  prepare_loanbook_for_matching(overwrite = overwrite_demo)

prep_loanbook
#> # A tibble: 638 x 6
#>    level      id    name                     sector source  simpler_name        
#>    <chr>      <chr> <chr>                    <chr>  <chr>   <chr>               
#>  1 direct_lo~ C294  yuamen power company     coal   manual  yuamenpower co      
#>  2 ultimate_~ UP15  alpine india             power  manual  alpineindia         
#>  3 direct_lo~ C293  Yuamen Changyuan Hydrop~ power  loanbo~ yuamenchangyuanhydr~
#>  4 ultimate_~ UP84  Eco Wave Power           power  loanbo~ ecowavepower        
#>  5 direct_lo~ C292  Yuama Ethanol Llc        power  loanbo~ yuamaethanol llc    
#>  6 ultimate_~ UP288 University Of Iowa       power  loanbo~ universityofiowa    
#>  7 direct_lo~ C299  Yudaksel Holding A.S     power  loanbo~ yudakselhldgs as    
#>  8 ultimate_~ UP54  China Electric Power (F~ power  loanbo~ chinaelectricpowerf~
#>  9 direct_lo~ C305  Yukon Energy Corp 1736   power  loanbo~ yukonenergycorpones~
#> 10 ultimate_~ UP104 Garland Power & Light    power  loanbo~ garlandpowerlight   
#> # ... with 628 more rows
```

`match_all_against_all()` scores the similarity between `simpler_name`
values in the prepared loanbook and ald datasets. The `by_sector`
argument, flags if names should only be compared against ald names in
the same sector. (setting `by_sector = TRUE` reduces the matching
runtime on large datasets, and reduces the amount of nonsensical
matches).

``` r
# Using default `by_sector = TRUE`
matched <- match_all_against_all(prep_loanbook, prep_ald)

matched
#> # A tibble: 64,303 x 3
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
#> # ... with 64,293 more rows
```

You may use common dplyr functions to recover all columns from the
loanbook dataset and to keep only rows at and above some threshold.

``` r
threshold <- 0.9

matched %>%
  left_join(prep_loanbook, by = c("simpler_name_x" = "simpler_name")) %>%
  filter(score >= threshold)
#> # A tibble: 416 x 8
#>    simpler_name_x   simpler_name_y   score level   id    name      sector source
#>    <chr>            <chr>            <dbl> <chr>   <chr> <chr>     <chr>  <chr> 
#>  1 astonmartin      astonmartin          1 ultima~ UP23  Aston Ma~ autom~ loanb~
#>  2 avtozaz          avtozaz              1 ultima~ UP25  Avtozaz   autom~ loanb~
#>  3 bogdan           bogdan               1 ultima~ UP36  Bogdan    autom~ loanb~
#>  4 chauto           chauto               1 ultima~ UP52  Ch Auto   autom~ loanb~
#>  5 chehejia         chehejia             1 ultima~ UP53  Chehejia  autom~ loanb~
#>  6 chtcauto         chtcauto             1 ultima~ UP58  Chtc Auto autom~ loanb~
#>  7 dongfenghonda    dongfenghonda        1 ultima~ UP80  Dongfeng~ autom~ loanb~
#>  8 dongfengluxgen   dongfengluxgen       1 ultima~ UP79  Dongfeng~ autom~ loanb~
#>  9 electricmobilit~ electricmobilit~     1 ultima~ UP89  Electric~ autom~ loanb~
#> 10 faradayfuture    faradayfuture        1 ultima~ UP94  Faraday ~ autom~ loanb~
#> # ... with 406 more rows
```

This matching data-frame should be saved and manually verified. To do
so, try something like:

``` r
readr::write_csv(matched, "path/to/save/matches_to_be_verified.csv")
```

and open the .csv in excel/ google sheets/ however you want to edit a
spreadsheet. Once open, compare `simpler_name_x` and `simpler_name_y`
manually, along with the loanbook sector. If you are happy with the
match, set the `score` value to `1` (Note: Only values of exactly `1`
will be considered valid, all other potential matches will be considered
invalidated.)

When you are happy with the match validation:

    readr::read_csv("path/to/load/verified_matches.csv")

**Work in progress, next step of analysis it to join in validated
matches in order of priority**.
