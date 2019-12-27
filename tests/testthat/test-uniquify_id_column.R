library(r2dii.dataraw)

test_that("uniquify_id_column overwrites id_ultimate_parent", {
  lbk <- loanbook_demo
  lbk$id_ultimate_parent <- "bla"

  out <- uniquify_id_column(
    lbk,
    id_column = "id_ultimate_parent", prefix = "UP"
  )

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

  out <- uniquify_id_column(
    lbk,
    id_column = "id_direct_loantaker", prefix = "UP"
  )

  expect_false(
    identical(
      out$id_direct_loantaker,
      lbk$id_direct_loantaker
    )
  )
})

test_that("uniquify_id_column prints its output (fix not returned result)", {
  # https://github.com/2DegreesInvesting/r2dii.match/pull/
  # 6#pullrequestreview-301599396
  out <- capture.output(
    uniquify_id_column(
      loanbook_demo,
      id_column = "id_ultimate_parent", prefix = "UP"
    )
  )
  expect_false(identical(out, character(0)))
})

test_that("uniquify_id_column returns a tibble dataframe", {
  out <- uniquify_id_column(
    loanbook_demo,
    id_column = "id_ultimate_parent", prefix = "UP"
  )
  expect_is(out, "tbl_df")
})

test_that("uniquify_id_column errs gracefully with wrong input", {
  invalidate <- function(data, x) {
    dplyr::rename(data, BAD = x)
  }

  expect_error_must_have_column <- function(data, id_col, invalid_col) {
    expect_error(
      uniquify_id_column(
        invalidate(data, invalid_col),
        id_column = id_col,
        prefix = "any"
      ),
      sprintf("must have.*%s", invalid_col)
    )
  }

  expect_error_must_have_column(
    loanbook_demo,
    id_col = "id_direct_loantaker",
    invalid_col = "id_direct_loantaker"
  )

  expect_error_must_have_column(
    loanbook_demo,
    id_col = "id_ultimate_parent",
    invalid_col = "id_ultimate_parent"
  )

  expect_error_must_have_column(
    loanbook_demo,
    id_col = "id_direct_loantaker",
    invalid_col = "name_direct_loantaker"
  )

  expect_error_must_have_column(
    loanbook_demo,
    id_col = "id_ultimate_parent",
    invalid_col = "name_ultimate_parent"
  )

  expect_error_must_have_column(
    loanbook_demo,
    id_col = "id_direct_loantaker",
    invalid_col = "sector_classification_direct_loantaker"
  )
})
