test_that("select_chr works a single match per pattern", {
  x <- c("ax", "bx")
  expect_equal(
    select_chr(x, starts_with("b"), starts_with("a")),
    c("bx", "ax")
  )
})

test_that("select_chr works with a multiple matches of one pattern", {
  x <- c("ax", "ay")
  expect_equal(select_chr(x, starts_with("a")), x)
})

test_that("select_chr works with less matching items than data items", {
  x <- c("ax", "bx")
  expect_equal(select_chr(x, starts_with("b")), "bx")
})

test_that("select_chr works with ambiguous matches", {
  x <- c("ax", "bx")
  expect_equal(select_chr(x, matches("x")), x)
})

test_that("select_chr works with a vector containing duplicated items", {
  x <- c("a", "a", "b")
  expect_equal(select_chr(x, "a"), "a")
})
