library(dplyr)

test_that("match_all_against_all outputs a tibble", {
  x <- tibble(sector = "A", alias = "a")
  y <- tibble(sector = "A", alias = "a")

  expect_is(match_all_against_all(x, y), "tbl_df")
})

test_that("match_all_against_all has the expected names", {
  x <- tibble(sector = "A", alias = "a")
  y <- tibble(sector = "A", alias = "a")

  expect_named(
    match_all_against_all(x, y),
    c("alias_lbk", "alias_ald", "score")
  )

  expect_named(
    match_all_against_all(x, y, by_sector = FALSE),
    c("alias_lbk", "alias_ald", "score")
  )
})

test_that("match_all_against_all is sensitive to by_sector", {
  x <- tibble(sector = c("A", "B"), alias = c("a", "ab"))
  y <- tibble(sector = c("A", "B"), alias = c("a", "cd"))

  expect_false(
    identical(
      match_all_against_all(x, y, by_sector = TRUE),
      match_all_against_all(x, y, by_sector = FALSE)
    )
  )
})

test_that("match_all_against_all scores extreme cases correctly", {
  x <- tibble(sector = c("A", "B"), alias = c("a", "ab"))
  y <- tibble(sector = c("A", "B"), alias = c("a", "cd"))
  expect_equal(
    match_all_against_all(x, y),
    tribble(
      ~alias_lbk, ~alias_ald, ~score,
      "a", "a", 1,
      "ab", "cd", 0,
    )
  )
})

test_that("match_all_against_all w/out crucial cols errors gracefully", {
  bad <- tibble(alias = "a")
  y <- tibble(sector = "A", alias = "a")
  expect_error(
    match_all_against_all(bad, y),
    "must have.*alias"
  )

  bad <- tibble(sector = "A")
  y <- tibble(sector = "A", alias = "a")
  expect_error(
    match_all_against_all(bad, y),
    "must have.*sector"
  )
})

test_that("match_all_against_all combines all alias of x and y", {
  x <- tibble(sector = c("A", "A"), alias = c("a", "b"))
  y <- tibble(sector = c("A", "A"), alias = c("c", "d"))

  out <- match_all_against_all(x, y)

  expect_equal(out$alias_lbk, c("a", "a", "b", "b"))
  expect_equal(out$alias_ald, c("c", "d", "c", "d"))
})

test_that("match_all_against_all with `by_sector = FALSE` outputs
  all combinations of alias in x and y", {
  x <- tibble(sector = c("A", "B", "B"), alias = c("xa", "xb", "xc"))
  y <- tibble(sector = c("A", "B", "C"), alias = c("ya", "yb", "yc"))

  actual <- match_all_against_all(x, y, by_sector = FALSE)
  expect <- tribble(
    ~alias_lbk, ~alias_ald, ~score,
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

test_that("match_all_against_all w/by_sector errors w/out `sector`", {
  x <- tibble(alias = "a")
  y <- tibble(alias = "a")

  expect_error(match_all_against_all(x, y, by_sector = TRUE))
  expect_error(match_all_against_all(x, y, by_sector = FALSE), NA)
})

test_that("match_all_against_all handles NA", {
  x <- tibble(sector = "A", alias = NA)
  y <- tibble(sector = "A", alias = "a")
  expect_equal(match_all_against_all(x, y)$alias_lbk, NA)

  x <- tibble(sector = "A", alias = "a")
  y <- tibble(sector = "A", alias = NA)
  expect_equal(match_all_against_all(x, y)$alias_ald, NA)

  x <- tibble(sector = "A", alias = NA)
  y <- tibble(sector = "A", alias = "a")
  s_n_x <- match_all_against_all(x, y, by_sector = FALSE)$alias_lbk
  expect_equal(s_n_x, NA)

  x <- tibble(sector = "A", alias = "a")
  y <- tibble(sector = "A", alias = NA)

  s_n_y <- match_all_against_all(x, y, by_sector = FALSE)$alias_ald
  expect_equal(s_n_y, NA)
})

test_that("match_all_agains_all passes arguments to score_similarity", {
  x <- tibble(sector = "A", alias = "a")
  y <- tibble(sector = "A", alias = "ab")

  expect_false(
    identical(
      match_all_against_all(x, y, p = 0.1),
      match_all_against_all(x, y, p = 0.2)
    )
  )
})

test_that("match_all_agains_all passes arguments to stringdist::stringdist", {
  x <- tibble(sector = "A", alias = "a")
  y <- tibble(sector = "A", alias = "ab")

  expect_false(
    identical(
      match_all_against_all(x, y, weight = c(0.1, 0.1, 0.1)),
      match_all_against_all(x, y, weight = c(0.5, 0.5, 0.5))
    )
  )
})

test_that("match_all_against_all checks used dots", {
  x <- tibble(sector = "A", alias = "a")
  y <- tibble(sector = "A", alias = "a")

  # Not checking `class` because it caused unexpected error on TravisCI when
  # R version was other than release and oldrel
  expect_error(match_all_against_all(x, y, bad_argument = "bad_argument"))
})

test_that("match_all_against_all w/ same `alias` in 2 sectors and
          by_sector = TRUE outputs no `NA`", {
  x <- tibble(sector = c("A", "B"), alias = "a")
  y <- tibble(sector = "A", alias = "a")
  expect_equal(
    match_all_against_all(x, y, by_sector = TRUE),
    tibble(alias_lbk = "a", alias_ald = "a", score = 1)
  )
})

test_that("match_all_against_all outputs unique rows", {
  # Known problematic data
  lbk <- loanbook_demo %>%
    filter(name_direct_loantaker == "Tata Group")

  out <- match_all_against_all(
    restructure_loanbook_for_matching(lbk),
    restructure_ald_for_matching(ald_demo)
  )

  expect_equal(nrow(out), nrow(unique(out)))
})
