test_that("score_simpler_name_by_sector outputs a tibble", {
  x <- tibble(sector = "A", simpler_name = "a")
  y <- tibble(sector = "A", simpler_name = "a")
  expect_is(score_simpler_name_by_sector(x, y), "tbl_df")
})

test_that("score_simpler_name_by_sector scores extreeme cases correctly", {
  x <- tibble(sector = c("A", "B"), simpler_name = c("a", "ab"))
  y <- tibble(sector = c("A", "B"), simpler_name = c("a", "cd"))
  expect_equal(
    score_simpler_name_by_sector(x, y),
    tibble::tribble(
      ~sector, ~simpler_name.x, ~simpler_name.y, ~score,
      "A",     "a",             "a",             1,
      "B",     "ab",            "cd",            0,
    )
  )
})

test_that("score_simpler_name_by_sector w/out crucial cols errors gracefully", {
  bad <- tibble(simpler_name = "a")
  y <- tibble(sector = "A", simpler_name = "a")
  expect_error(
    score_simpler_name_by_sector(bad, y),
    "must have.*simpler_name"
  )

  bad <- tibble(sector = "A")
  y <- tibble(sector = "A", simpler_name = "a")
  expect_error(
    score_simpler_name_by_sector(bad, y),
    "must have.*sector"
  )
})

test_that("score_simpler_name_by_sector combines all simpler_name of x and y", {
  x <- tibble(sector = c("A", "A"), simpler_name = c("a", "b"))
  y <- tibble(sector = c("A", "A"), simpler_name = c("c", "d"))

  out <- score_simpler_name_by_sector(x, y)

  expect_equal(out$simpler_name.x, c("a", "a", "b", "b"))
  expect_equal(out$simpler_name.y, c("c", "d", "c", "d"))
})
