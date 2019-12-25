library(dplyr)
library(r2dii.dataraw)

test_that("match_name takes unprepared loanbook and ald datasets", {
  expect_error(
    match_name(loanbook_demo, ald_demo),
    NA
  )
})

test_that("match_name takes `min_score`", {
  expect_error(
    match_name(loanbook_demo, ald_demo, min_score = 0.5),
    NA
  )
})

test_that("match_name takes `by_sector`", {
  expect_false(
    identical(
      match_name(loanbook_demo, ald_demo, by_sector = TRUE),
      match_name(loanbook_demo, ald_demo, by_sector = FALSE)
    )
  )
})

test_that("match_name has all formals in match_all_against_all", {
  actual <- names(formals("match_name"))
  expected <- names(formals("match_all_against_all"))
  expect_equal(setdiff(expected, actual), character(0))
})

test_that("match_name recovers `sector_x`", {
  expect_true(
    rlang::has_name(match_name(loanbook_demo, ald_demo), "sector_x")
  )
})

test_that("match_name recovers `sector_y`", {
  expect_true(
    rlang::has_name(match_name(loanbook_demo, ald_demo), "sector_y")
  )
})

test_that("match_name outputs name from loanbook, not name.y (bug fix)", {
  out <- match_name(loanbook_demo, ald_demo)
  expect_false(has_name(out, "name.y"))
})

test_that("match_name outputs original columns", {
  out <- match_name(loanbook_demo, ald_demo)
  expect_length(setdiff(names(loanbook_demo), names(out)), 0L)
  setdiff(names(out), names(loanbook_demo))
})

test_that("match_name works with `min_score = 0` (bug fix)", {
  expect_error(match_name(loanbook_demo, ald_demo, min_score = 0), NA)
})
