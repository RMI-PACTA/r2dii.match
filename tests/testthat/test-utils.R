test_that("check_crucial_names with expected names returns `x` invisibly", {
  x <- c(a = 1)
  expect_silent(out <- check_crucial_names(x, "a"))
  expect_identical(x, out)

  x <- data.frame(a = 1)
  expect_silent(out <- check_crucial_names(x, "a"))
  expect_identical(x, out)
})

test_that("check_crucial_names with expected names returns `x` invisibly", {
  x <- c(a = 1)
  expect_error(check_crucial_names(x, "b"), "must have all expected names")

  x <- data.frame(a = 1)
  expect_error(check_crucial_names(x, "b"), "must have all expected names")
})
