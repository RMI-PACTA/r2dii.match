test_that("id_by_loantaker_sector prints its output", {
  out <- capture.output(id_by_loantaker_sector(id_by_loantaker_sector(r2dii.dataraw::loanbook_demo)))
  expect_false(identical(out, character(0)))
})

test_that("id_by_loantaker_sector returns a tibble dataframe", {
  out <- id_by_loantaker_sector(id_by_loantaker_sector(r2dii.dataraw::loanbook_demo))
  expect_is(out, "tbl_df")
})

test_that("id_by_loantaker_sector errs gracefully with wrong input", {

  invalidate <- function(data, x) {
    dplyr::rename(data, bad = x)
  }

  lbk <- r2dii.dataraw::loanbook_demo
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
