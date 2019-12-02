
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://i.imgur.com/3jITMq8.png" align="right" height=40 /> Match loanbook with asset level data

<!-- badges: start -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/r2dii.match)](https://CRAN.R-project.org/package=r2dii.match)
<!-- badges: end -->

The goal of r2dii.match is to match loanbook data with asset level data
(ald).

## Installation

Install the development version of r2dii.match with something like this:

``` r
# install.packages("devtools")

# To install from a private repo, see ?usethis::browse_github_token()
devtools::install_github("2DegreesInvesting/r2dii.match", auth_token = "abc")
```

## Example

This example aims to shows the entire matching process. As usual, we
start by using required packages.

``` r
library(r2dii.match)
library(r2dii.dataraw)
#> Loading required package: r2dii.utils
```

Before matching, both the loanbook and asset level data must be
prepared.

``` r
# All `r2dii.dataraw::*_demo` are fake datasets for examples

prep_loanbook <- r2dii.dataraw::loanbook_demo %>% 
  # identifies unique combinations of "loan-takers + sector"
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

`match_all_against_all()` scores the similarity between `simpler_name`
values in the prepared loanbook and ald datasets.

``` r
# Using default `by_sector = TRUE`
matched <- match_all_against_all(prep_loanbook, prep_ald)

matched
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

You may use common dplyr functions to recover all columns from the
loanbook dataset and to keep only rows at and above some threshold.

``` r
threshold <- 0.9

matched %>% 
  dplyr::left_join(prep_loanbook, by = c("simpler_name_x" = "simpler_name")) %>%
  dplyr::filter(score >= threshold)
#> # A tibble: 418 x 8
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
#> # ... with 408 more rows
```
