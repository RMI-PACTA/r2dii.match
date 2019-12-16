library(dplyr)

test_that("match_loanbook_with_ald takes `threshold`", {
  x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
  y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))

  expect_error(
    match_loanbook_with_ald(x, y, threshold = 0.5),
    NA
  )
})

test_that("match_loanbook_with_ald takes `by_sector`", {
  x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
  y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))

  out1 <- match_all_against_all(x, y, by_sector = TRUE)
  out2<- match_all_against_all(x, y, by_sector = FALSE)
  expect_false(identical(out1, out2))
})

test_that("match_loanbook_with_ald has all formals in match_all_against_all", {
  actual <- names(formals("match_loanbook_with_ald"))
  expected <- names(formals("match_all_against_all"))
  expect_equal(setdiff(expected, actual), character(0))
})

test_that("match_loanbook_with_ald recovers `sector_x`", {
  x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
  y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))

  expect_true(
    rlang::has_name(match_loanbook_with_ald(x, y), "sector_x")
  )
})

test_that("match_loanbook_with_ald recovers `sector_y`", {
  x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
  y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))

  expect_true(
    rlang::has_name(match_loanbook_with_ald(x, y), "sector_y")
  )
})

test_that("match_loanbook_with_ald has all columns in loanbook and ald", {
  x <- tibble(lbk_column = "col",  sector = "a", simpler_name = "xa")
  y <- tibble(ald_column = "col",  sector = "a", simpler_name = "ya")

  expect_true(
    rlang::has_name(match_loanbook_with_ald(x, y), "lbk_column")
  )

  expect_true(
    rlang::has_name(match_loanbook_with_ald(x, y, threshold = 0), "ald_column")
  )
})
