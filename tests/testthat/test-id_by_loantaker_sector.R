library(r2dii.dataraw)

test_that("id_by_loantaker_sector overwrites id_ultimate_parent", {
  lbk <- loanbook_demo
  lbk$id_ultimate_parent <- "bla"

  expect_false(
    identical(
      id_by_loantaker_sector(lbk)$id_ultimate_parent,
      lbk$id_ultimate_parent
    )
  )
})

test_that("id_by_loantaker_sector overwrites id_direct_loantaker", {
  lbk <- loanbook_demo
  lbk$id_ultimate_parent <- "bla"

  expect_false(
    identical(
      id_by_loantaker_sector(lbk)$id_direct_loantaker,
      lbk$id_direct_loantaker
    )
  )
})

test_that("id_by_loantaker_sector prints its output (fix not returned result)", {
  # https://github.com/2DegreesInvesting/r2dii.match/pull/
  # 6#pullrequestreview-301599396
  out <- capture.output(
    id_by_loantaker_sector(loanbook_demo)
  )
  expect_false(identical(out, character(0)))
})

test_that("id_by_loantaker_sector returns a tibble dataframe", {
  out <- id_by_loantaker_sector(loanbook_demo)
  expect_is(out, "tbl_df")
})

test_that("id_by_loantaker_sector errs gracefully with wrong input", {
  invalidate <- function(data, x) {
    dplyr::rename(data, bad = x)
  }

  lbk <- loanbook_demo
  expect_error(
    id_by_loantaker_sector(invalidate(lbk, "name_direct_loantaker")),
    "must have.*name_direct_loantaker"
  )
  expect_error(
    id_by_loantaker_sector(invalidate(lbk, "sector_classification_direct_loantaker")),
    "must have.*sector_classification_direct_loantaker"
  )
  expect_error(
    id_by_loantaker_sector(invalidate(lbk, "name_ultimate_parent")),
    "must have.*name_ultimate_parent"
  )
  expect_error(
    id_by_loantaker_sector(invalidate(lbk, "id_direct_loantaker")),
    "must have.*id_direct_loantaker"
  )
  expect_error(
    id_by_loantaker_sector(invalidate(lbk, "id_ultimate_parent")),
    "must have.*id_ultimate_parent"
  )
})
