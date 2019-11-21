library(r2dii.dataraw)

test_that("pull_unique_name_sector_combinations_ald outputs a tibble", {
  out <- pull_unique_name_sector_combinations_ald(
    ald_demo
  )

  expect_is(out, "tbl_df")
})

test_that("pull_unique_name_sector_combinations_ald errors if data lacks key column", {
  bad_data <- ald_demo %>%
    dplyr::select(-sector)

  expect_error(
    pull_unique_name_sector_combinations_ald(bad_data),
    "data must have all expected names"
  )
})

test_that("pull_unique_name_sector_combinations_ald remains unchanged after refactoring", {
  out <- pull_unique_name_sector_combinations_ald(
    ald_demo
  )
  expect_known_value(out, "ref-pull_unique_name_sector_combinations_ald", update = FALSE)
})
