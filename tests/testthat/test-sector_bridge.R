test_that("sector_bridge returns a tibble dataframe", {
  out <- sector_bridge(sector_bridge(r2dii.dataraw::loanbook_demo))
  expect_is(out, "tbl_df")
})

test_that("sector_bridge errs gracefully with wrong input", {

  invalidate <- function(data, x) {
    dplyr::rename(data, bad = x)
  }

  lbk <- r2dii.dataraw::loanbook_demo
  expect_error(
    sector_bridge(invalidate(lbk, "name_direct_loantaker")),
    "must have.*sector_classification_system"
  )
  expect_error(
    sector_bridge(invalidate(lbk, "sector_classification_direct_loantaker")),
    "must have.*sector_classification_direct_loantaker"
  )

})
