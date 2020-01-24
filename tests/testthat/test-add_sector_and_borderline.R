library(r2dii.dataraw)

test_that("add_sector_and_borderline()$borderline is of type logical", {
  expect_is(
    add_sector_and_borderline(loanbook_demo)$borderline,
    "logical"
  )
})

test_that("add_sector_and_borderline outputs known output", {
  expect_known_output(
    add_sector_and_borderline(loanbook_demo),
    "ref-add_sector_and_borderline",
    update = FALSE
  )
})

test_that("add_sector_and_borderline returns a tibble dataframe", {
  expect_is(
    add_sector_and_borderline(loanbook_demo),
    "tbl_df"
  )
})

test_that("add_sector_and_borderline with wrong input errs gracefully", {
  expect_error(
    add_sector_and_borderline(
      select(loanbook_demo, -sector_classification_system)
    ),
    "must have.*sector_classification_system"
  )

  expect_error(
    add_sector_and_borderline(
      select(loanbook_demo, -sector_classification_direct_loantaker)
    ),
    "must have.*sector_classification_direct_loantaker"
  )
})

test_that("add_sector_and_borderline adds two columns: `sector` and `borderline`", {
  expect_false(has_name(loanbook_demo, "sector"))
  expect_false(has_name(loanbook_demo, "borderline"))

  out <- add_sector_and_borderline(loanbook_demo)
  new_columns <- sort(setdiff(names(out), names(loanbook_demo)))
  expect_equal(
    new_columns, c("borderline", "sector")
  )
})

test_that("add_sector_and_borderline added columns return acceptable values", {
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
    all(
      add_sector_and_borderline(loanbook_demo)$sector %in% acceptable_sectors
    )
  )
})

test_that("add_sector_and_borderline preserves typeof() input columns", {
  out <- add_sector_and_borderline(loanbook_demo)

  expect_equal(
    purrr::map_chr(loanbook_demo, typeof),
    purrr::map_chr(out[names(loanbook_demo)], typeof),
  )
})

test_that("add_sector_and_borderline outputs no missing value of `sector`", {
  out <- add_sector_and_borderline(loanbook_demo)
  expect_false(any(is.na(out$sector)))
})

test_that("add_sector_and_borderline outputs no missing value of `borderline`", {
  out <- add_sector_and_borderline(loanbook_demo)
  expect_false(any(is.na(out$borderline)))
})

test_that("check_is_attached works as expected", {
  expect_error(
    check_is_attached("nonexistent"),
    "nonexistent must be attached"
  )
})
