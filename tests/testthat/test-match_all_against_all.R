library(tibble)

test_that("match_all_against_all outputs a tibble", {
  x <- tibble(sector = "A", simpler_name = "a")
  y <- tibble(sector = "A", simpler_name = "a")

  expect_is(match_all_against_all(x, y), "tbl_df")
})

test_that("match_all_against_all has the expected names", {
  x <- tibble(sector = "A", simpler_name = "a")
  y <- tibble(sector = "A", simpler_name = "a")

  expect_named(
    match_all_against_all(x, y),
    c("simpler_name_x", "simpler_name_y", "score")
  )

  expect_named(
    match_all_against_all(x, y, group_by_sector = FALSE),
    c("simpler_name_x", "simpler_name_y", "score")
  )
})

test_that("match_all_against_all scores extreeme cases correctly", {
  x <- tibble(sector = c("A", "B"), simpler_name = c("a", "ab"))
  y <- tibble(sector = c("A", "B"), simpler_name = c("a", "cd"))
  expect_equal(
    match_all_against_all(x, y),
    tibble::tribble(
      ~simpler_name_x, ~simpler_name_y, ~score,
      "a", "a", 1,
      "ab", "cd", 0,
    )
  )
})

test_that("match_all_against_all w/out crucial cols errors gracefully", {
  bad <- tibble(simpler_name = "a")
  y <- tibble(sector = "A", simpler_name = "a")
  expect_error(
    match_all_against_all(bad, y),
    "must have.*simpler_name"
  )

  bad <- tibble(sector = "A")
  y <- tibble(sector = "A", simpler_name = "a")
  expect_error(
    match_all_against_all(bad, y),
    "must have.*sector"
  )
})

test_that("match_all_against_all combines all simpler_name of x and y", {
  x <- tibble(sector = c("A", "A"), simpler_name = c("a", "b"))
  y <- tibble(sector = c("A", "A"), simpler_name = c("c", "d"))

  out <- match_all_against_all(x, y)

  expect_equal(out$simpler_name_x, c("a", "a", "b", "b"))
  expect_equal(out$simpler_name_y, c("c", "d", "c", "d"))
})

test_that("match_all_against_all with `group_by_sector = FALSE` outputs
  all combinations of simpler_name in x and y", {
  x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
  y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))

  actual <- match_all_against_all(x, y, group_by_sector = FALSE)
  expect <- tribble(
    ~simpler_name_x, ~simpler_name_y, ~score,
    "xa", "ya", 0.667,
    "xa", "yb", 0,
    "xa", "yc", 0,
    "xb", "ya", 0,
    "xb", "yb", 0.667,
    "xb", "yc", 0,
    "xc", "ya", 0,
    "xc", "yb", 0,
    "xc", "yc", 0.667,
  )

  expect_equal(actual[1:2], expect[1:2])
  expect_equal(round(actual$score, 3), round(expect$score, 3))
})

test_that("match_all_against_all w/group_by_sector errors w/out `sector`", {
  x <- tibble(simpler_name = "a")
  y <- tibble(simpler_name = "a")

  expect_error(match_all_against_all(x, y, group_by_sector = TRUE))
  expect_error(match_all_against_all(x, y, group_by_sector = FALSE), NA)
})

test_that("match_all_against_all handles NA", {
  x <- tibble(sector = "A", simpler_name = NA)
  y <- tibble(sector = "A", simpler_name = "a")
  expect_equal(match_all_against_all(x, y)$simpler_name_x, NA)

  x <- tibble(sector = "A", simpler_name = "a")
  y <- tibble(sector = "A", simpler_name = NA)
  expect_equal(match_all_against_all(x, y)$simpler_name_y, NA)

  x <- tibble(sector = "A", simpler_name = NA)
  y <- tibble(sector = "A", simpler_name = "a")
  s_n_x <- match_all_against_all(x, y, group_by_sector = FALSE)$simpler_name_x
  expect_equal(s_n_x, NA)

  x <- tibble(sector = "A", simpler_name = "a")
  y <- tibble(sector = "A", simpler_name = NA)

  s_n_y <- match_all_against_all(x, y, group_by_sector = FALSE)$simpler_name_y
  expect_equal(s_n_y, NA)
})

test_that("match_all_agains_all passes arguments to string_similarity", {
  x <- tibble(sector = "A", simpler_name = "a")
  y <- tibble(sector = "A", simpler_name = "ab")

  expect_false(
    identical(
      match_all_against_all(x, y, p = 0.1),
      match_all_against_all(x, y, p = 0.2)
    )
  )
})

test_that("match_all_agains_all passes arguments to stringdist::stringdist", {
  x <- tibble(sector = "A", simpler_name = "a")
  y <- tibble(sector = "A", simpler_name = "ab")

  expect_false(
    identical(
      match_all_against_all(x, y, weight = c(0.1, 0.1, 0.1)),
      match_all_against_all(x, y, weight = c(0.5, 0.5, 0.5))
    )
  )
})


test_that("match_all_against_all checks used dots", {
  x <- tibble(sector = "A", simpler_name = "a")
  y <- tibble(sector = "A", simpler_name = "a")

  expect_error(
    match_all_against_all(x, y, bad_argument = "bad_argument"),
    "problematic arguments",
    class = "rlib_error_dots_unused"
  )
})
