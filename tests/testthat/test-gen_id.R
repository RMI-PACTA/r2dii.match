test_that("gen_id prints its output", {
  out <- capture.output(gen_id(gen_id(r2dii.dataraw::loanbook_demo)))
  expect_false(identical(out, character(0)))
})

test_that("gen_id returns a tibble dataframe", {
  out <- gen_id(gen_id(r2dii.dataraw::loanbook_demo))
  expect_is(out, "tbl_df")
})
