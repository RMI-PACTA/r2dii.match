library(dplyr)
library(r2dii.data)

test_that("takes unprepared loanbook and ald datasets", {
  expect_no_error(
    match_name2(slice(loanbook_demo, 1), ald_scenario_demo)
  )
})
