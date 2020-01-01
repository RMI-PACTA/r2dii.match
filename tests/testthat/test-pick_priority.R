library(dplyr)

test_that("prioritize_at with ungrouped data picks the highest priority row", {
  out <- tibble(x = c("a", "z")) %>%
    prioritize_at(.at = "x", priority = c("z", "a"))

  expect_equal(out$x, "z")
})

test_that("prioritize_at with grouped data picks one row per group", {
  out <- tibble(
    x = c(1, 2, 2),
    y = c("a", "a", "z")
  ) %>%
    group_by(x) %>%
    prioritize_at(.at = "y", priority = c("z", "a")) %>%
    arrange(x)

  expect_equal(out$y, c("a", "z"))
})

test_that("prioritize_at does not warn if a group has not all priority items", {
  expect_warning(
    tibble(x = c("a", "z"), y = x) %>%
      group_by(y) %>%
      prioritize_at(.at = "x", priority = c("z", "a")),
    NA
  )
})

test_that("prioritize_at accepts `priority = NULL`", {
  expect_error(
    tibble(x = "a") %>% prioritize_at("x"),
    NA
  )
})
