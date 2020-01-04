# add_sector_and_borderline() needs r2dii.dataraw in the search() path
library(r2dii.dataraw)

test_that("add_sector_and_borderline()$borderline is of type logical", {
  out <- add_sector_and_borderline(r2dii.dataraw::loanbook_demo)
  expect_is(out$borderline, "logical")
})

test_that("add_sector_and_borderline outputs known output", {
  out <- add_sector_and_borderline(r2dii.dataraw::loanbook_demo)
  expect_known_output(out, "ref-add_sector_and_borderline", update = FALSE)
})

test_that("add_sector_and_borderline returns a tibble dataframe", {
  out <- add_sector_and_borderline(r2dii.dataraw::loanbook_demo)
  expect_is(out, "tbl_df")
})

test_that("add_sector_and_borderline with wrong input errs gracefully", {
  rename_crucial_column <- function(data, x) {
    dplyr::rename(data, bad = x)
  }
  lbk <- r2dii.dataraw::loanbook_demo

  lbk_missing_sector_classification_system <-
    rename_crucial_column(lbk, "sector_classification_system")
  expect_error(
    add_sector_and_borderline(lbk_missing_sector_classification_system),
    "must have.*sector_classification_system"
  )

  lbk_missing_sector_classification_direct_loantaker <-
    rename_crucial_column(lbk, "sector_classification_direct_loantaker")
  expect_error(
    add_sector_and_borderline(lbk_missing_sector_classification_direct_loantaker),
    "must have.*sector_classification_direct_loantaker"
  )
})

test_that("add_sector_and_borderline adds two columns: `sector` and `borderline`", {
  input <- r2dii.dataraw::loanbook_demo
  expect_false(has_name(input, "sector"))
  expect_false(has_name(input, "borderline"))

  output <- add_sector_and_borderline(input)
  new_columns <- sort(setdiff(names(output), names(input)))
  expect_equal(
    new_columns, c("borderline", "sector")
  )
})

test_that("add_sector_and_borderline added columns return acceptable values", {
  input <- r2dii.dataraw::loanbook_demo
  output <- add_sector_and_borderline(input)

  acceptable_sectors <- c(
    "automotive",
    "aviation",
    "cement",
    "coal",
    "code not found",
    "not in scope",
    "oil and gas",
    "power",
    "shipping",
    "steel"
  )

  expect_true(
    all(output$sector %in% acceptable_sectors)
  )
})

test_that("add_sector_and_borderline preserves typeof() input columns", {
  input <- r2dii.dataraw::loanbook_demo
  output <- add_sector_and_borderline(input)

  expect_equal(
    purrr::map_chr(input, typeof),
    purrr::map_chr(output[names(input)], typeof),
  )
})

test_that("add_sector_and_borderline outputs no missing value of `sector`", {
  out <- add_sector_and_borderline(r2dii.dataraw::loanbook_demo)
  expect_false(any(is.na(out$sector)))
})

test_that("add_sector_and_borderline outputs no missing value of `borderline`", {
  out <- add_sector_and_borderline(r2dii.dataraw::loanbook_demo)
  expect_false(any(is.na(out$borderline)))
})

test_that("add_sector_and_borderline with bad sector code system errs gracefully", {
  bad_classification <- r2dii.dataraw::loanbook_demo %>%
    mutate(sector_classification_system = "BAD_CLASSIFICATION")

  expect_error(
    add_sector_and_borderline(bad_classification),
    "must use 2dfii's sector code system"
  )
})

test_that("check_is_attached works as expected", {
  expect_error(
    check_is_attached("nonexistent"),
    "nonexistent must be attached"
  )
})
