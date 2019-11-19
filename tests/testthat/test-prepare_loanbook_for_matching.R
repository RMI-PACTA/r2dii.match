library(r2dii.dataraw)

test_that("prepare_loanbook_for_matching outputs unique `id` values", {
  out <- prepare_loanbook_for_matching(
    bridge_sector(loanbook_demo)
  )

  expect_false(
    any(duplicated(out$id))
  )
})

test_that("prepare_loanbook_for_matching outputs a tibble", {
  out <- prepare_loanbook_for_matching(
    bridge_sector(loanbook_demo)
  )

  expect_is(out, "tbl_df")
})
