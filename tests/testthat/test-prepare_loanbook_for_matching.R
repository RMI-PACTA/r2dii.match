test_that("ensure prepared loanbook has no duplicated ID values", {
  out <- prepare_loanbook_for_matching(r2dii.dataraw:loanbook_demo)
  expect_false(
    anyDuplicated(out$id)
  )
})
