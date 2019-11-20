library(r2dii.dataraw)

test_that("prepare_loanbook_for_matching", {
  out <- prepare_loanbook_for_matching(r2dii.dataraw::loanbook_demo)
  expect_is(out, "tbl_df")
  expect_named(
    out,
    c("level", "id", "name", "sector", "source", "simpler_name")
  )

  out2 <- prepare_loanbook_for_matching(loanbook_demo, overwrite_demo)
  expect_is(out2, "tbl_df")
  expect_named(
    out2,
    c("level", "id", "name", "sector", "source", "simpler_name")
  )
})
