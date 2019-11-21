library(r2dii.dataraw)

test_that("prepare_ald_for_matching", {
  out <- prepare_ald_for_matching(r2dii.dataraw::ald_demo)
  expect_is(out, "tbl_df")
  expect_named(
    out,
    c("name", "sector", "simpler_name")
  )

  out2 <- prepare_ald_for_matching(ald_demo)
  expect_is(out2, "tbl_df")
  expect_named(
    out2,
    c("name", "sector", "simpler_name")
  )
})
