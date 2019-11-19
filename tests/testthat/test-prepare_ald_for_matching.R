library(r2dii.dataraw)

test_that("prepare_ald_for_matching outputs a tibble", {
  out <- prepare_ald_for_matching(
    ald_demo
  )

  expect_is(out, "tbl_df")
})

test_that("prepare_ald_for_matching errors if data lacks key column", {
  bad_data <- ald_demo %>%
    dplyr::select(-sector)

  expect_error(
    prepare_ald_for_matching(bad_data),
    "data must have all expected names"
  )
})
