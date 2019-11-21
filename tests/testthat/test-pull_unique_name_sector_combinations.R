library(r2dii.dataraw)

test_that("pull_unique_name_sector_combinations outputs unique `id` values", {
  out <- pull_unique_name_sector_combinations(
    bridge_sector(loanbook_demo)
  )

  expect_false(
    any(duplicated(out$id))
  )
})

test_that("pull_unique_name_sector_combinations outputs a tibble", {
  out <- pull_unique_name_sector_combinations(
    bridge_sector(loanbook_demo)
  )

  expect_is(out, "tbl_df")
})

test_that("pull_unique_name_sector_combinations remains unchanged after refactoring", {
  out <- pull_unique_name_sector_combinations(
    bridge_sector(loanbook_demo)
  )
  expect_known_value(out, "ref-pull_unique_name_sector_combinations", update = FALSE)
})

test_that("pull_unique_name_sector_combinations errors if data lacks key column", {
  bad_data <- loanbook_demo %>%
    bridge_sector() %>%
    dplyr::select(-sector)

  expect_error(
    pull_unique_name_sector_combinations(bad_data),
    "data must have all expected names"
  )
})
