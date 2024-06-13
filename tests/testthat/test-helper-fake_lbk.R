test_that("fake_lbk w/ lenght-2 input outpus 2 rows", {
  expect_equal(nrow(fake_lbk(c("a", "a"))), 2L)
})

test_that("fake_abcd w/ lenght-2 input outpus 2 rows", {
  expect_equal(nrow(fake_abcd(c("a", "a"))), 2L)
})

test_that("fake_matched w/ lenght-2 input outpus 2 rows", {
  expect_equal(nrow(fake_matched(c("a", "a"))), 2L)
})

test_that("fake_lbk creates new columns", {
  expect_named(
    fake_lbk(new1 = 1, new2 = 1),
    c(names(fake_lbk()), "new1", "new2")
  )
})
