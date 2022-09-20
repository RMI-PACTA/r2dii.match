library(r2dii.data)

test_that("uniquify_id_column overwrites id_ultimate_parent", {
  lbk <- loanbook_demo
  lbk$id_ultimate_parent <- "bla"

  out <- uniquify_id_column(lbk, id_column = "id_ultimate_parent")

  expect_false(
    identical(
      out$id_ultimate_parent,
      lbk$id_ultimate_parent
    )
  )
})

test_that("uniquify_id_column overwrites id_direct_loantaker", {
  lbk <- loanbook_demo
  lbk$id_direct_loantaker <- "bla"

  out <- uniquify_id_column(lbk, id_column = "id_direct_loantaker")

  expect_false(
    identical(
      out$id_direct_loantaker,
      lbk$id_direct_loantaker
    )
  )
})

test_that("uniquify_id_column prints its output (fix not returned result)", {
  # https://github.com/RMI-PACTA/r2dii.match/pull/
  # 6#pullrequestreview-301599396
  out <- capture.output(
    uniquify_id_column(
      loanbook_demo,
      id_column = "id_ultimate_parent"
    )
  )
  expect_false(identical(out, character(0)))
})

test_that("warns unknown intermediate column", {
  expect_warning(
    uniquify_id_column(fake_lbk(), "unknown_intermediate_column"),
    "unknown_intermediate_column.*not.*found"
  )
})
