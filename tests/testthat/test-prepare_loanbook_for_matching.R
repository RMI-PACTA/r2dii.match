library(r2dii.dataraw)

test_that("prepare_loanbook_for_matching outputs unique `id` values", {
  out <- prepare_loanbook_for_matching(
    bridge_sector(loanbook_demo)
  )

  expect_false(
    any(duplicated(out$id))
  )
})

test_that("prepare_loanbook_for_matching outputs a tibble", {
  out <- prepare_loanbook_for_matching(
    bridge_sector(loanbook_demo)
  )

  expect_is(out, "tbl_df")
})

test_that("prepare_loanbook_for_matching remains unchanged after refactoring", {
  out <- prepare_loanbook_for_matching(
    bridge_sector(loanbook_demo)
  )
  expect_known_value(out, "ref-prepare_loanbook_for_matching", update = FALSE)
})

test_that("prepare_loanbook_for_matching errors if data lacks key column", {
  bad_data <- loanbook_demo %>%
    bridge_sector() %>%
    dplyr::select(-sector)

  expect_error(
    prepare_loanbook_for_matching(bad_data),
    "data must have all expected names"
  )
})

test_that("prepare_loanbook_for_matching errors if overwrite lacks key column", {
  data <- loanbook_demo %>%
    bridge_sector()
  bad_overwrite <- tibble(x = 1)

  expect_error(
    prepare_loanbook_for_matching(data, bad_overwrite),
    "data must have all expected names"
  )
})
