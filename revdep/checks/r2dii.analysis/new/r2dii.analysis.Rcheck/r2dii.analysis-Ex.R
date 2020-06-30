pkgname <- "r2dii.analysis"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('r2dii.analysis')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("join_ald_scenario")
### * join_ald_scenario

flush(stderr()); flush(stdout())

### Name: join_ald_scenario
### Title: Join a data-loanbook object to the ald and scenario
### Aliases: join_ald_scenario

### ** Examples

installed <- requireNamespace("r2dii.data", quietly = TRUE) &&
  requireNamespace("r2dii.match", quietly = TRUE)
if (!installed) stop("Please install r2dii.match and r2dii.data")

library(r2dii.data)
library(r2dii.match)

valid_matches <- match_name(loanbook_demo, ald_demo) %>%
  # WARNING: Remember to validate matches (see `?prioritize`)
  prioritize()

valid_matches %>%
  join_ald_scenario(
    ald = ald_demo,
    scenario = scenario_demo_2020,
    region_isos = region_isos_demo
  )



cleanEx()
nameEx("summarize_weighted_production")
### * summarize_weighted_production

flush(stderr()); flush(stdout())

### Name: summarize_weighted_production
### Title: Summarize production based on the weight of each loan per sector
###   per year
### Aliases: summarize_weighted_production

### ** Examples

library(r2dii.analysis)
library(r2dii.data)
library(r2dii.match)

master <- r2dii.data::loanbook_demo %>%
  r2dii.match::match_name(r2dii.data::ald_demo) %>%
  r2dii.match::prioritize() %>%
  join_ald_scenario(r2dii.data::ald_demo,
    r2dii.data::scenario_demo_2020,
    region_isos = region_isos_demo
  )

summarize_weighted_production(master)

summarize_weighted_production(master, use_credit_limit = TRUE)



cleanEx()
nameEx("target_market_share")
### * target_market_share

flush(stderr()); flush(stdout())

### Name: target_market_share
### Title: Add targets for production, using the market share approach
### Aliases: target_market_share

### ** Examples

library(r2dii.analysis)
library(r2dii.data)
library(r2dii.match)

match_result <- r2dii.data::loanbook_demo %>%
  r2dii.match::match_name(r2dii.data::ald_demo) %>%
  r2dii.match::prioritize()

# calculate targets at portfolio level
target_market_share(match_result,
  ald = r2dii.data::ald_demo,
  scenario = r2dii.data::scenario_demo_2020,
  region_isos = r2dii.data::region_isos_demo
)

# calculate targets at company level
target_market_share(match_result,
  ald = r2dii.data::ald_demo,
  scenario = r2dii.data::scenario_demo_2020,
  region_isos = r2dii.data::region_isos_demo,
  by_company = TRUE
)




cleanEx()
nameEx("target_sda")
### * target_sda

flush(stderr()); flush(stdout())

### Name: target_sda
### Title: Add targets for CO2 emissions per unit production at the
###   portfolio level, using the SDA approach
### Aliases: target_sda

### ** Examples

installed <- requireNamespace("r2dii.data", quietly = TRUE) &&
  requireNamespace("r2dii.match", quietly = TRUE)
if (!installed) stop("Please install r2dii.match and r2dii.data")

library(r2dii.data)
library(r2dii.match)

valid_matches <- match_name(loanbook_demo, ald_demo) %>%
  # WARNING: Remember to validate matches (see `?prioritize`)
  prioritize()

out <- valid_matches %>%
  target_sda(
    ald = ald_demo,
    co2_intensity_scenario = co2_intensity_scenario_demo
  )

# The output includes the portfolio's actual projected emissions factors, the
# scenario pathway emissions factors, and the portfolio's target emissions
# factors.
out

# Split view by metric
split(out, out$emission_factor_metric)



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
