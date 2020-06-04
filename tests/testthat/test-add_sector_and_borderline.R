library(r2dii.data)

test_that("$borderline is of type logical", {
  expect_is(
    add_sector_and_borderline(loanbook_demo)$borderline,
    "logical"
  )
})

test_that("outputs known output", {
  expect_known_output(
    add_sector_and_borderline(loanbook_demo),
    "ref-add_sector_and_borderline",
    update = FALSE
  )
})

test_that("returns a tibble data frame", {
  expect_is(
    add_sector_and_borderline(loanbook_demo),
    "tbl_df"
  )
})

test_that("adds two columns: `sector` and `borderline`", {
  expect_false(has_name(loanbook_demo, "sector"))
  expect_false(has_name(loanbook_demo, "borderline"))

  out <- add_sector_and_borderline(loanbook_demo)
  new_columns <- sort(setdiff(names(out), names(loanbook_demo)))
  expect_equal(
    new_columns, c("borderline", "sector")
  )
})

test_that("added columns return acceptable values", {
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

test_that("preserves typeof() input columns", {
  out <- add_sector_and_borderline(loanbook_demo)

  x <- unname(purrr::map_chr(loanbook_demo, typeof))
  y <- unname(purrr::map_chr(out[names(loanbook_demo)], typeof))
  expect_equal(x, y)
})

test_that("outputs no missing value of `sector`", {
  out <- add_sector_and_borderline(loanbook_demo)
  expect_false(any(is.na(out$sector)))
})

test_that("outputs no missing value of `borderline`", {
  out <- add_sector_and_borderline(loanbook_demo)
  expect_false(any(is.na(out$borderline)))
})
