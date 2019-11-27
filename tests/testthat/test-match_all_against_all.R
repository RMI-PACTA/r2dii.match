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

