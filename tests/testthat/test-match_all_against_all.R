test_that("match_all_against_all with `group_by_sector = FALSE` outputs
  all combinations of simpler_name in x and y", {
  x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
  y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))

  actual <- match_all_against_all(x, y, group_by_sector = FALSE)
  expect <- tibble::tribble(
    ~ simpler_name.x, ~ simpler_name.y, ~ sector.x, ~ sector.y, ~ score,
    "xa",             "ya",             "A",        "A",        "0.667",
    "xa",             "yb",             "A",        "B",        "0",
    "xa",             "yc",             "A",        "C",        "0",
    "xb",             "ya",             "B",        "A",        "0",
    "xb",             "yb",             "B",        "B",        "0.667",
    "xb",             "yc",             "B",        "C",        "0",
    "xc",             "ya",             "B",        "A",        "0",
    "xc",             "yb",             "B",        "B",        "0",
    "xc",             "yc",             "B",        "C",        "0.667",
  )

  expect_equal(actual, expect)
})

test_that("match_all_against_all outputs a tibble", {
  x <- tibble(sector = "A", simpler_name = "a")
  y <- tibble(sector = "A", simpler_name = "a")
  expect_is(match_all_against_all(x, y), "tbl_df")
})

test_that("match_all_against_all scores extreeme cases correctly", {
  x <- tibble(sector = c("A", "B"), simpler_name = c("a", "ab"))
  y <- tibble(sector = c("A", "B"), simpler_name = c("a", "cd"))
  expect_equal(
    match_all_against_all(x, y),
    tibble::tribble(
      ~sector, ~simpler_name.x, ~simpler_name.y, ~score,
      "A",     "a",             "a",             1,
      "B",     "ab",            "cd",            0,
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

  expect_equal(out$simpler_name.x, c("a", "a", "b", "b"))
  expect_equal(out$simpler_name.y, c("c", "d", "c", "d"))
})

