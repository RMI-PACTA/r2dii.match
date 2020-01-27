# Source: https://github.com/r-lib/rlang/blob/master/tests/testthat/helper-cnd.R

expect_no_error <- function(...) {
  expect_error(regexp = NA, ...)
}

expect_no_warning <- function(...) {
  expect_warning(regexp = NA, ...)
}
