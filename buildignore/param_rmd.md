Parametrized Rmarkdown
================

This is a parametrized Rmarkdown document. It provides a GUI for the
user to provide parameters, and an easy way for developers to use those
parameters in R code.

## User perspective

To access the graphical user interface, go to *Knit \> Knit with
Parameters …*

![](https://i.imgur.com/SgY2me1.png)

![](https://i.imgur.com/26PsRsw.png)

Now edit the parameters and “Knit”. The underlying R code will now do
whatever it’s been designed to do.

## Developer perspective

To create a parametrized Rmarkdown document simply add the `param:`
field to the YAML header. For example:

    ---
    title: "Parametrized Rmarkdown"
    params:
      loanbook_path: "loanbook.csv"
      do_match: yes
      do_analyze: no
    ---

Now the each parameter is available via `params$<value>`, for example:

``` r
params$do_match
#> [1] TRUE
params$do_analyze
#> [1] FALSE

path <- params$loanbook_path
readr::read_csv(path)
#> # A tibble: 32 x 11
#>      mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1  21       6  160    110  3.9   2.62  16.5     0     1     4     4
#>  2  21       6  160    110  3.9   2.88  17.0     0     1     4     4
#>  3  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
#>  4  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
#>  5  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
#>  6  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
#>  7  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
#>  8  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
#>  9  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
#> 10  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
#> # ... with 22 more rows
```
