library(dplyr)

test_that("score_alias_similarity outputs a tibble", {
  x <- tibble(sector = "A", alias = "a")
  y <- tibble(sector = "A", alias = "a")

  expect_is(score_alias_similarity(x, y), "tbl_df")
})

test_that("score_alias_similarity has the expected names", {
  x <- tibble(sector = "A", alias = "a")
  y <- tibble(sector = "A", alias = "a")

  expect_named(
    score_alias_similarity(x, y),
    c("alias_lbk", "alias_ald", "sector", "score")
  )

  expect_named(
    score_alias_similarity(x, y, by_sector = FALSE),
    c("alias_lbk", "alias_ald", "sector", "score")
  )
})

test_that("score_alias_similarity is sensitive to by_sector", {
  x <- tibble(sector = c("A", "B"), alias = c("a", "ab"))
  y <- tibble(sector = c("A", "B"), alias = c("a", "cd"))

  expect_false(
    identical(
      score_alias_similarity(x, y, by_sector = TRUE),
      score_alias_similarity(x, y, by_sector = FALSE)
    )
  )
})

test_that("score_alias_similarity scores extreme cases correctly", {
  x <- tibble(sector = c("A", "B"), alias = c("a", "ab"))
  y <- tibble(sector = c("A", "B"), alias = c("a", "cd"))
  expect_equal(
    score_alias_similarity(x, y),
    # styler: off
    tribble(
      ~alias_lbk, ~alias_ald, ~sector,  ~score,
      "a",        "a",        "A",      1,
      "ab",       "cd",       "B",      0,
    )
    # styler: on
  )
})

test_that("score_alias_similarity combines all alias of x and y", {
  x <- tibble(sector = c("A", "A"), alias = c("a", "b"))
  y <- tibble(sector = c("A", "A"), alias = c("c", "d"))

  out <- score_alias_similarity(x, y)

  expect_equal(out$alias_lbk, c("a", "a", "b", "b"))
  expect_equal(out$alias_ald, c("c", "d", "c", "d"))
})

test_that("score_alias_similarity with `by_sector = FALSE` outputs
  all combinations of alias in x and y", {
  x <- tibble(sector = c("A", "B", "B"), alias = c("xa", "xb", "xc"))
  y <- tibble(sector = c("A", "B", "C"), alias = c("ya", "yb", "yc"))

  actual <- score_alias_similarity(x, y, by_sector = FALSE)
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

test_that("score_alias_similarity w/by_sector errors w/out `sector`", {
  x <- tibble(alias = "a")
  y <- tibble(alias = "a")

  expect_error(score_alias_similarity(x, y, by_sector = TRUE))
  expect_error(score_alias_similarity(x, y, by_sector = FALSE), NA)
})

test_that("score_alias_similarity handles NA", {
  x <- tibble(sector = "A", alias = NA)
  y <- tibble(sector = "A", alias = "a")
  expect_equal(score_alias_similarity(x, y)$alias_lbk, NA)

  x <- tibble(sector = "A", alias = "a")
  y <- tibble(sector = "A", alias = NA)
  expect_equal(score_alias_similarity(x, y)$alias_ald, NA)

  x <- tibble(sector = "A", alias = NA)
  y <- tibble(sector = "A", alias = "a")
  s_n_x <- score_alias_similarity(x, y, by_sector = FALSE)$alias_lbk
  expect_equal(s_n_x, NA)

  x <- tibble(sector = "A", alias = "a")
  y <- tibble(sector = "A", alias = NA)

  s_n_y <- score_alias_similarity(x, y, by_sector = FALSE)$alias_ald
  expect_equal(s_n_y, NA)
})

test_that("match_all_agains_all passes arguments to score_string_similarity", {
  x <- tibble(sector = "A", alias = "a")
  y <- tibble(sector = "A", alias = "ab")

  expect_false(
    identical(
      score_alias_similarity(x, y, p = 0.1),
      score_alias_similarity(x, y, p = 0.2)
    )
  )
})

test_that("score_alias_similarity w/ same `alias` in 2 sectors and
          by_sector = TRUE outputs no `NA`", {
  x <- tibble(sector = c("A", "B"), alias = "a")
  y <- tibble(sector = "A", alias = "a")
  expect_equal(
    score_alias_similarity(x, y, by_sector = TRUE),
    tibble(alias_lbk = "a", alias_ald = "a", sector = c("A", "B"), score = 1)
  )
})

test_that("score_alias_similarity outputs unique rows", {
  # Known problematic data
  lbk <- loanbook_demo %>%
    tibble::rowid_to_column() %>%
    filter(name_direct_loantaker == "Tata Group")

  out <- score_alias_similarity(
    restructure_loanbook_for_matching(lbk),
    restructure_ald_for_matching(ald_demo)
  )

  expect_equal(nrow(out), nrow(unique(out)))
})
