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

test_that("match_name outputs expected names found in loanbook (after tweaks)", {
  out <- match_name(loanbook_demo, ald_demo)

  strip_suffix_lbk <- function(x) sub("_lbk$", "", x)
  names_in_level_column <- unique(out$level_lbk)
  tweaked <- strip_suffix_lbk(c(names(out), names_in_level_column))

  expect_length(setdiff(names(loanbook_demo), tweaked), 0L)
})

test_that("match_name works with `min_score = 0` (bug fix)", {
  expect_error(match_name(loanbook_demo, ald_demo, min_score = 0), NA)
})

test_that("match_name outputs a reasonable number of rows", {
  out <- match_name(loanbook_demo, ald_demo)

  expected <- match_all_against_all(
    restructure_loanbook_for_matching(loanbook_demo),
    restructure_ald_for_matching(ald_demo)
  ) %>%
    filter(score >= 0.8) %>%
    prefer_perfect_match_by(.data$alias_lbk)

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

test_that("match name outputs only perfect matches if any (#40 @2diiKlaus)", {
  this_name <- "Nanaimo Forest Products Ltd."
  this_alias <- to_alias(this_name)
  this_lbk <- loanbook_demo %>%
    filter(name_direct_loantaker == this_name)

  nanimo_scores <- this_lbk %>%
    match_name(ald_demo) %>%
    filter(alias_lbk == this_alias) %>%
    pull(score)

  expect_true(
    any(nanimo_scores == 1)
  )
  expect_true(
    all(nanimo_scores == 1)
  )
})

test_that("prefer_perfect_match_by prefers score == 1 if `var` group has any", {
# styler: off
  data <- tribble(
    ~var, ~score,
        1,      1,
        2,      1,
        2,   0.99,
        3,   0.99,
  )
  # styler: on

  expect_equal(
    prefer_perfect_match_by(data, var),
    tibble(var = c(1, 2, 3), score = c(1, 1, 0.99))
  )
})

test_that("match_name has name `level`", {
  out <- match_name(loanbook_demo, ald_demo)
  expect_true(rlang::has_name(out, "level_lbk"))
})
