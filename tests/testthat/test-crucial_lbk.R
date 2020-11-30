test_that("outputs hasn't changed", {
  expected <- c(
    "id_ultimate_parent",
    "name_ultimate_parent",
    "id_direct_loantaker",
    "name_direct_loantaker",
    "sector_classification_system",
    "sector_classification_direct_loantaker"
  )
  expect_equal(crucial_lbk(), expected)
})
