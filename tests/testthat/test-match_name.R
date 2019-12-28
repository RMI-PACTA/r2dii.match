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

test_that("match_name takes `method`", {
  expect_false(
    identical(
      match_name(loanbook_demo, ald_demo, method = "jw"),
      match_name(loanbook_demo, ald_demo, method = "osa")
    )
  )
})

test_that("match_name takes `p`", {
  expect_false(
    identical(
      match_name(loanbook_demo, ald_demo, p = 0.1),
      match_name(loanbook_demo, ald_demo, p = 0.2)
    )
  )
})

test_that("match_name takes `overwrite`", {
  expect_false(
    identical(
      match_name(loanbook_demo, ald_demo, overwrite = NULL),
      match_name(loanbook_demo, ald_demo, overwrite = overwrite_demo)
    )
  )
})

test_that("match_name recovers `sector_lbk`", {
  expect_true(
    rlang::has_name(match_name(loanbook_demo, ald_demo), "sector_lbk")
  )
})

test_that("match_name recovers `sector_y`", {
  expect_true(
    rlang::has_name(match_name(loanbook_demo, ald_demo), "sector_ald")
  )
})

test_that("match_name outputs name from loanbook, not name.y (bug fix)", {
  out <- match_name(loanbook_demo, ald_demo)
  expect_false(has_name(out, "name.y"))
})

test_that("match_name columns in input loanbook (after stripping _lbk suffix", {
  strip_lbk <- function(x) sub("_lbk$", "", x)
  out <- match_name(loanbook_demo, ald_demo)

  expect_length(
    setdiff(
      names(set_names(loanbook_demo, strip_lbk)),
      names(set_names(out, strip_lbk))
    ),
    0L
  )
})

test_that("match_name works with `min_score = 0` (bug fix)", {
  expect_error(match_name(loanbook_demo, ald_demo, min_score = 0), NA)
})

test_that("match_name outputs a reasonable number of rows", {
  out <- match_name(loanbook_demo, ald_demo)

  expected <- match_all_against_all(
    prepare_loanbook_for_matching(loanbook_demo),
    prepare_ald_for_matching(ald_demo)
  ) %>%
    filter(score >= 0.8) %>%
    # FIXME: This is a temoprary patch
    rename(
      simpler_name_lbk = .data$simpler_name_x,
      simpler_name_ald = .data$simpler_name_y
    )

  nrows_out <- out %>%
    select(names(expected)) %>%
    unique() %>%
    nrow()

  expect_equal(nrows_out, nrow(expected))
})

test_that("match_name outputs known value", {
  skip("FIXME: Skipping to avoid inconsistent encoding in test() vs. check()")
  expect_known_value(match_name(loanbook_demo, ald_demo), "ref-match_name")
})

test_that("match_name names end with _lbk or _ald, except `score`", {
  out <- match_name(loanbook_demo, ald_demo)
  nms <- names(out)
  names_not_ending_with_lbk_or_ald <- nms[!grepl("_lbk$|_ald$", nms)]

  expect_equal(
    names_not_ending_with_lbk_or_ald,
    "score"
  )
})
