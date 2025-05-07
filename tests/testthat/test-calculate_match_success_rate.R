test_that("returns expected output", {
  loanbook <- fake_lbk(
    name_direct_loantaker = c("Steckel GmbH", "XXX"),
    sector_classification_direct_loantaker = c("C29.1", "C29.1"),
    loan_size_outstanding = c(1e6, 1e6),
    loan_size_credit_limit = c(1e7, 1e7)
  )
  matched <- match_name(loanbook = loanbook, abcd = r2dii.data::abcd_demo)
  out <- calculate_match_success_rate(matched = matched, loanbook = loanbook)

  expect_s3_class(object = out, class = "data.frame")
  expect_contains(object = names(out), expected = "matched")
  expect_identical(object = out$matched, expected = c("Matched", "Not Matched"))
})
