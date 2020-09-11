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
### Title: Summaries based on the weight of each loan per sector per year
### Aliases: summarize_weighted_production
###   summarize_weighted_percent_change

### ** Examples

installed <- requireNamespace("r2dii.data", quietly = TRUE) &&
  requireNamespace("r2dii.match", quietly = TRUE)
if (!installed) stop("Please install r2dii.match and r2dii.data")

library(r2dii.data)
library(r2dii.match)

master <- loanbook_demo %>%
  match_name(ald_demo) %>%
  prioritize() %>%
  join_ald_scenario(
    ald = ald_demo,
    scenario = scenario_demo_2020,
    region_isos = region_isos_demo
  )

summarize_weighted_production(master)

summarize_weighted_production(master, use_credit_limit = TRUE)

summarize_weighted_percent_change(master)

summarize_weighted_percent_change(master, use_credit_limit = TRUE)



cleanEx()
nameEx("target_market_share")
### * target_market_share

flush(stderr()); flush(stdout())

### Name: target_market_share
### Title: Add targets for production, using the market share approach
### Aliases: target_market_share

### ** Examples

installed <- requireNamespace("r2dii.data", quietly = TRUE) &&
  requireNamespace("r2dii.match", quietly = TRUE)
if (!installed) stop("Please install r2dii.match and r2dii.data")

library(r2dii.data)
library(r2dii.match)

matched <- loanbook_demo %>%
  match_name(ald_demo) %>%
  prioritize()

# Calculate targets at portfolio level
matched %>%
  target_market_share(
    ald = ald_demo,
    scenario = scenario_demo_2020,
    region_isos = region_isos_demo
  )

# Calculate targets at company level
matched %>%
  target_market_share(
    ald = ald_demo,
    scenario = scenario_demo_2020,
    region_isos = region_isos_demo,
    by_company = TRUE
  )

matched %>%
  target_market_share(
    ald = ald_demo,
    scenario = scenario_demo_2020,
    region_isos = region_isos_demo,
    # Calculate unweighted targets
    weight_production = FALSE
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

installed <- requireNamespace("r2dii.match", quietly = TRUE) &&
  requireNamespace("r2dii.data", quietly = TRUE)
if (!installed) stop("Please install r2dii.match and r2dii.data")

library(r2dii.match)
library(r2dii.data)

# Example datasets from r2dii.data
loanbook <- loanbook_demo
ald <- ald_demo
co2_scenario <- co2_intensity_scenario_demo

# WARNING: Remember to validate matches (see `?prioritize`)
matched <- prioritize(match_name(loanbook, ald))

# You may need to clean your data
anyNA(ald$emission_factor)
try(target_sda(matched, ald, co2_intensity_scenario = co2_scenario))

ald2 <- subset(ald, !is.na(emission_factor))
anyNA(ald2$emission_factor)

out <- target_sda(matched, ald2, co2_intensity_scenario = co2_scenario)

# The output includes the portfolio's actual projected emissions factors, the
# scenario pathway emissions factors, and the portfolio's target emissions
# factors.
out

# Split-view by metric
split(out, out$emission_factor_metric)

# Calculate company-level targets
out <- target_sda(
  matched, ald2,
  co2_intensity_scenario = co2_scenario,
  by_company = TRUE
)



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
