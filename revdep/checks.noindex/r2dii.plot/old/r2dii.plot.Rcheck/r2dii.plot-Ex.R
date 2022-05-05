pkgname <- "r2dii.plot"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('r2dii.plot')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("market_share")
### * market_share

flush(stderr()); flush(stdout())

### Name: market_share
### Title: An example of a 'market_share'-like dataset
### Aliases: market_share
### Keywords: datasets

### ** Examples

market_share



cleanEx()
nameEx("plot_emission_intensity")
### * plot_emission_intensity

flush(stderr()); flush(stdout())

### Name: plot_emission_intensity
### Title: Create an emission intensity plot
### Aliases: plot_emission_intensity

### ** Examples

# `data` must meet documented "Requirements"
data <- subset(sda, sector == "cement")
plot_emission_intensity(data)

# plot with `qplot_emission_intensity()` parameters
plot_emission_intensity(
  data,
  span_5yr = TRUE,
  convert_label = to_title
)



cleanEx()
nameEx("plot_techmix")
### * plot_techmix

flush(stderr()); flush(stdout())

### Name: plot_techmix
### Title: Create a techmix plot
### Aliases: plot_techmix

### ** Examples

# `data` must meet documented "Requirements"
data <- subset(
  market_share,
  scenario_source == "demo_2020" &
    sector == "power" &
    region == "global" &
    metric %in% c("projected", "corporate_economy", "target_sds")
)

plot_techmix(data)

# plot with `qplot_techmix()` parameters
plot_techmix(
  data,
  span_5yr = TRUE,
  convert_label = recode_metric_techmix,
  convert_tech_label = spell_out_technology
)



cleanEx()
nameEx("plot_trajectory")
### * plot_trajectory

flush(stderr()); flush(stdout())

### Name: plot_trajectory
### Title: Create a trajectory plot
### Aliases: plot_trajectory

### ** Examples

# `data` must meet documented "Requirements"
data <- subset(
  market_share,
  sector == "power" &
    technology == "renewablescap" &
    region == "global" &
    scenario_source == "demo_2020"
)

plot_trajectory(data)

# plot with `qplot_trajectory()` parameters
plot_trajectory(
  data,
  span_5yr = TRUE,
  convert_label = format_metric
)



cleanEx()
nameEx("qplot_emission_intensity")
### * qplot_emission_intensity

flush(stderr()); flush(stdout())

### Name: qplot_emission_intensity
### Title: Create a quick emission intensity plot
### Aliases: qplot_emission_intensity

### ** Examples

# `data` must meet documented "Requirements"
data <- subset(sda, sector == "cement")

qplot_emission_intensity(data)



cleanEx()
nameEx("qplot_techmix")
### * qplot_techmix

flush(stderr()); flush(stdout())

### Name: qplot_techmix
### Title: Create a quick techmix plot
### Aliases: qplot_techmix

### ** Examples

# `data` must meet documented "Requirements"
data <- subset(
  market_share,
  sector == "power" &
    region == "global" &
    scenario_source == "demo_2020" &
    metric %in% c("projected", "corporate_economy", "target_sds")
)

qplot_techmix(data)



cleanEx()
nameEx("qplot_trajectory")
### * qplot_trajectory

flush(stderr()); flush(stdout())

### Name: qplot_trajectory
### Title: Create a quick trajectory plot
### Aliases: qplot_trajectory

### ** Examples

# `data` must meet documented "Requirements"
data <- subset(
  market_share,
  sector == "power" &
    technology == "renewablescap" &
    region == "global" &
    scenario_source == "demo_2020"
)

qplot_trajectory(data)



cleanEx()
nameEx("r2dii_colours")
### * r2dii_colours

flush(stderr()); flush(stdout())

### Name: r2dii_colours
### Title: Colour datasets
### Aliases: r2dii_colours palette_colours scenario_colours sector_colours
###   technology_colours
### Keywords: datasets internal

### ** Examples

r2dii.plot:::palette_colours

r2dii.plot:::scenario_colours

r2dii.plot:::sector_colours

r2dii.plot:::technology_colours



cleanEx()
nameEx("scale_colour_r2dii")
### * scale_colour_r2dii

flush(stderr()); flush(stdout())

### Name: scale_colour_r2dii
### Title: Custom 2DII colour and fill scales
### Aliases: scale_colour_r2dii scale_color_r2dii scale_fill_r2dii

### ** Examples

library(ggplot2, warn.conflicts = FALSE)

ggplot(mpg) +
  geom_point(aes(displ, hwy, color = class)) +
  scale_colour_r2dii()

ggplot(mpg) +
  geom_histogram(aes(cyl, fill = class), position = "dodge", bins = 5) +
  scale_fill_r2dii()



cleanEx()
nameEx("scale_colour_r2dii_sector")
### * scale_colour_r2dii_sector

flush(stderr()); flush(stdout())

### Name: scale_colour_r2dii_sector
### Title: Custom 2DII sector colour and fill scales
### Aliases: scale_colour_r2dii_sector scale_color_r2dii_sector
###   scale_fill_r2dii_sector

### ** Examples

library(ggplot2, warn.conflicts = FALSE)

ggplot(mpg) +
  geom_point(aes(displ, hwy, color = class)) +
  scale_colour_r2dii_sector()

ggplot(mpg) +
  geom_histogram(aes(cyl, fill = class), position = "dodge", bins = 5) +
  scale_fill_r2dii_sector()



cleanEx()
nameEx("scale_colour_r2dii_tech")
### * scale_colour_r2dii_tech

flush(stderr()); flush(stdout())

### Name: scale_colour_r2dii_tech
### Title: Custom 2DII technology colour and fill scales
### Aliases: scale_colour_r2dii_tech scale_color_r2dii_tech
###   scale_fill_r2dii_tech

### ** Examples

library(ggplot2, warn.conflicts = FALSE)

ggplot(mpg) +
  geom_point(aes(displ, hwy, color = class)) +
  scale_colour_r2dii_tech("automotive")

ggplot(mpg) +
  geom_histogram(aes(cyl, fill = class), position = "dodge", bins = 5) +
  scale_fill_r2dii_tech("automotive")



cleanEx()
nameEx("sda")
### * sda

flush(stderr()); flush(stdout())

### Name: sda
### Title: An example of an 'sda'-like dataset
### Aliases: sda
### Keywords: datasets

### ** Examples

sda



cleanEx()
nameEx("theme_2dii")
### * theme_2dii

flush(stderr()); flush(stdout())

### Name: theme_2dii
### Title: Complete theme
### Aliases: theme_2dii

### ** Examples

library(ggplot2, warn.conflicts = FALSE)

ggplot(mtcars) +
  geom_histogram(aes(mpg), bins = 10) +
  theme_2dii()



cleanEx()
nameEx("to_title")
### * to_title

flush(stderr()); flush(stdout())

### Name: to_title
### Title: Replicate labels produced with qplot_*() functions
### Aliases: to_title format_metric recode_metric_techmix
###   spell_out_technology

### ** Examples

to_title(c("a.string", "another_STRING"))

metric <- c("projected", "corporate_economy", "target_xyz", "else")
format_metric(metric)

recode_metric_techmix(metric)

spell_out_technology(c("gas", "ice", "coalcap", "hdv"))



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
