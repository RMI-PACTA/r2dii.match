test_that("gen_id prints its output", {
  out <- capture.output(gen_id(gen_id(r2dii.dataraw::loanbook_demo)))
  expect_false(identical(out, character(0)))
})

test_that("gen_id returns a tibble dataframe", {
  out <- gen_id(gen_id(r2dii.dataraw::loanbook_demo))
  expect_is(out, "tbl_df")
})

test_that("gen_id errs gracefully with wrong input", {

  invalidate <- function(data, x) {
    dplyr::rename(data, bad = x)
  }

  lbk <- r2dii.dataraw::loanbook_demo
  expect_error(
    gen_id(invalidate(lbk, "name_direct_loantaker")),
    "must have.*name_direct_loantaker"
  )
  expect_error(
    gen_id(invalidate(lbk, "sector_classification_direct_loantaker")),
    "must have.*sector_classification_direct_loantaker"
  )
  expect_error(
    gen_id(invalidate(lbk, "name_ultimate_parent")),
    "must have.*name_ultimate_parent"
  )
  expect_error(
    gen_id(invalidate(lbk, "id_direct_loantaker")),
    "must have.*id_direct_loantaker"
  )
  expect_error(
    gen_id(invalidate(lbk, "id_ultimate_parent")),
    "must have.*id_ultimate_parent"
  )

})
