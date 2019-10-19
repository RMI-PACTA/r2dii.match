test_that("sector_bridge returns a tibble dataframe", {
  library(r2dii.dataraw)
  out <- sector_bridge(sector_bridge(r2dii.dataraw::loanbook_demo))
  expect_is(out, "tbl_df")
})

test_that("sector_bridge errs gracefully with wrong input", {
  rename_crucial_column <- function(data, x) {
    dplyr::rename(data, bad = x)
  }
  lbk <- r2dii.dataraw::loanbook_demo

  lbk_missing_sector_classification_system <-
    rename_crucial_column(lbk, "sector_classification_system")
  expect_error(
    sector_bridge(lbk_missing_sector_classification_system),
    "must have.*sector_classification_system"
  )

  lbk_missing_sector_classification_direct_loantaker <-
    rename_crucial_column(lbk, "sector_classification_direct_loantaker")
  expect_error(
    sector_bridge(lbk_missing_sector_classification_direct_loantaker),
    "must have.*sector_classification_direct_loantaker"
  )
})
