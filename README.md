
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://i.imgur.com/3jITMq8.png" align="right" height=40 /> Match loanbook with asset level data

<!-- badges: start -->

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/r2dii.match)](https://CRAN.R-project.org/package=r2dii.match)
<!-- badges: end -->

The goal of r2dii.match is to match loanbook data with asset level data.

## Installation

Install the development version of r2dii.match with something like this:

``` r
# install.packages("devtools")

# To install from a private repo, see ?usethis::browse_github_token()
devtools::install_github("2DegreesInvesting/r2dii.match", auth_token = "abc")
```

## Example

For an approximation of what this package will eventually do see [this
flowchart](https://docs.google.com/document/d/10smLkRUIIc5zRYltx1jXLuTpEXslw018ihEq9LSQ3kA/edit?ts=5d7bae6c#heading=h.ogg9badrp207).

A great place to see the documentation of this package is in its private
website.

``` r
library(r2dii)
#> Loading required package: r2dii.dataprep
#> Loading required package: r2dii.dataraw

if (interactive()) {
  browse_private_site()
}
```

In an interactive session you should see something like this:

![](https://i.imgur.com/YIXj8GF.png)
