# bridge_sector() needs r2dii.dataraw in the search() path
library(r2dii.dataraw)

test_that("bridge_sector outputs known output", {
  out <- bridge_sector(r2dii.dataraw::loanbook_demo)
  expect_known_output(out, "ref-bridge_sector", update = FALSE)
})

test_that("bridge_sector returns a tibble dataframe", {
  out <- bridge_sector(r2dii.dataraw::loanbook_demo)
  expect_is(out, "tbl_df")
})

test_that("bridge_sector with wrong input errs gracefully", {
  rename_crucial_column <- function(data, x) {
    dplyr::rename(data, bad = x)
  }
  lbk <- r2dii.dataraw::loanbook_demo

  lbk_missing_sector_classification_system <-
    rename_crucial_column(lbk, "sector_classification_system")
  expect_error(
    bridge_sector(lbk_missing_sector_classification_system),
    "must have.*sector_classification_system"
  )

  lbk_missing_sector_classification_direct_loantaker <-
    rename_crucial_column(lbk, "sector_classification_direct_loantaker")
  expect_error(
    bridge_sector(lbk_missing_sector_classification_direct_loantaker),
    "must have.*sector_classification_direct_loantaker"
  )
})

test_that("bridge_sector adds two columns: `sector` and `borderline`", {
  input <- r2dii.dataraw::loanbook_demo
  expect_false(hasName(input, "sector"))
  expect_false(hasName(input, "borderline"))

  output <- bridge_sector(input)
  new_columns <- sort(setdiff(names(output), names(input)))
  expect_equal(
    new_columns, c("borderline", "sector")
  )
})

test_that("bridge_sector added columns return acceptable values", {
  input <- r2dii.dataraw::loanbook_demo
  output <- bridge_sector(input)

  acceptable_sectors <- c("automotive", "aviation", "cement", "coal",
                          "code not found", "not in scope", "oil and gas",
                          "power", "shipping", "steel")

  expect_true(
    all(output$sector %in% acceptable_sectors)
    )
})

test_that("bridge_sector preserves typeof() input columns", {
  input <- r2dii.dataraw::loanbook_demo
  output <- bridge_sector(input)

  expect_equal(
    purrr::map_chr(input, typeof),
    purrr::map_chr(output[names(input)], typeof),
  )
})

test_that("bridge_sector outputs no missing value of `sector`", {
  out <- bridge_sector(r2dii.dataraw::loanbook_demo)
  expect_false(any(is.na(out$sector)))
})

test_that("bridge_sector outputs no missing value of `borderline`", {
  out <- bridge_sector(r2dii.dataraw::loanbook_demo)
  expect_false(any(is.na(out$borderline)))
})

test_that("bridge_sector with bad sector code system errs gracefully", {
  bad_classification <- r2dii.dataraw::loanbook_demo %>%
    dplyr::mutate(sector_classification_system = "BAD_CLASSIFICATION")

  expect_error(
    bridge_sector(bad_classification),
    "must use 2dfii's sector code system"
  )
})

