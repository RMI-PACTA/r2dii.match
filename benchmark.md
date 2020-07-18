Benchmark `match_name()` in development vs. on CRAN
================

``` r
library(r2dii.data)
library(tidyverse)
#> ── Attaching packages ───────────────────── tidyverse 1.3.0 ──
#> ✓ ggplot2 3.3.2     ✓ purrr   0.3.4
#> ✓ tibble  3.0.3     ✓ dplyr   1.0.0
#> ✓ tidyr   1.1.0     ✓ stringr 1.4.0
#> ✓ readr   1.3.1     ✓ forcats 0.5.0
#> ── Conflicts ──────────────────────── tidyverse_conflicts() ──
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
```

Setup 2 different versions of `match_name`: (1) in development and (2)
on cran.

``` r
# The older version on CRAN
packageVersion("r2dii.match")
#> [1] '0.0.3'

# Copy of match_name on CRAN
cran <- r2dii.match::match_name

# The newer version on the PR "profile"
devtools::load_all()
#> Loading r2dii.match
#> 
#> Attaching package: 'testthat'
#> The following object is masked from 'package:dplyr':
#> 
#>     matches
#> The following object is masked from 'package:purrr':
#> 
#>     is_null
#> The following object is masked from 'package:tidyr':
#> 
#>     matches
# The newer version in development
packageVersion("r2dii.match")
#> [1] '0.0.3.9000'

# Copy of match_name in development
devel <- r2dii.match::match_name
```

Both versions have different source code.

``` r
# Confirm the two versions of `match_name` are different
identical(devel, cran)
#> [1] FALSE

# Show some data.table code
head(tail(devel, 20))
#>                                                                                  
#> 22     }                                                                         
#> 23     l <- rename(prep_lbk, alias_lbk = .data$alias)                            
#> 24     setDT(l)                                                                  
#> 25     matched <- a[l, on = "alias_lbk", nomatch = 0]                            
#> 26     matched <- matched[, `:=`(pick, none_is_one(score) | some_is_one(score)), 
#> 27         by = id_2dii][pick == TRUE][, `:=`(pick, NULL)]

# Show some dplyr code
head(tail(cran, 20))
#>                                                                                     
#> 6      loanbook_rowid <- tibble::rowid_to_column(loanbook)                          
#> 7      prep_lbk <- suppressMessages(restructure_loanbook(loanbook_rowid,            
#> 8          overwrite = overwrite))                                                  
#> 9      prep_ald <- restructure_ald_for_matching(ald)                                
#> 10     matched <- score_alias_similarity(prep_lbk, prep_ald, by_sector = by_sector, 
#> 11         method = method, p = p) %>% pick_min_score(min_score)
```

Version in development uses less memory and runs faster.

``` r
benchmark <- bench::mark(
  # Don't check that the output is identical; rows-order is different^[1]
  check = FALSE,
  iterations = 5,
  out_devel = out_devel <- devel(loanbook_demo, ald_demo),
  out_cran  = out_cran  <-  cran(loanbook_demo, ald_demo)
)
#> Warning: Some expressions had a GC in every iteration; so filtering is disabled.

benchmark
#> # A tibble: 2 x 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 out_devel   161.3ms    168ms     5.28         NA     4.23
#> 2 out_cran       1.1s     1.2s     0.776        NA     5.90

benchmark %>%
  summarise(
    # How many times less memory is allocating the version in development?^[2]
    times_less_memory  = as.double(mem_alloc)[[2]]  / as.double(mem_alloc)[[1]],
    # How many times faster is the version in development?
    times_less_time    = as.double(total_time)[[2]] / as.double(total_time)[[1]]
  )
#> # A tibble: 1 x 2
#>   times_less_memory times_less_time
#>               <dbl>           <dbl>
#> 1                NA            6.81
```

Notes:

  - `[1]`: Caveat: If we reorder the rows in the same way, both outputs
    are equivalent.

<!-- end list -->

``` r
testthat::expect_equivalent(
  out_devel %>% arrange(across(names(.))),
  out_cran  %>% arrange(across(names(.)))
)
```

  - `[2]: In Rmarkdown I fail to get a result for`times\_less\_memory`;
    in the console I get`times\_less\_memory`of up to 5.5;
    and`times\_less\_time\` of up to 9.
