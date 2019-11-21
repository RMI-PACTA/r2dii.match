library(r2dii.dataraw)

test_that("prepare_loanbook_for_matching errors gracefully with bad input", {
  expect_error(
    prepare_loanbook_for_matching("bad"),
    "data.frame.*is not TRUE"
  )

  expect_error(
    prepare_loanbook_for_matching(loanbook_demo, overwrite = "bad"),
    "data.frame.*is not TRUE"
  )
})

test_that("prepare_loanbook_for_matching", {
  out <- prepare_loanbook_for_matching(loanbook_demo)
  expect_false(any(duplicated(out$id)))
})

test_that("prepare_loanbook_for_matching outputs a tibble with expected names", {
  out <- prepare_loanbook_for_matching(r2dii.dataraw::loanbook_demo)
  expect_is(out, "tbl_df")
  expect_named(
    out,
    c("level", "id", "name", "sector", "source", "simpler_name")
  )

  out2 <- prepare_loanbook_for_matching(loanbook_demo, overwrite_demo)
  expect_is(out2, "tbl_df")
  expect_named(
    out2,
    c("level", "id", "name", "sector", "source", "simpler_name")
  )
})

test_that("prepare_loanbook_for_matching errors with bad overwrite columns", {
  expect_error(
    prepare_loanbook_for_matching(loanbook_demo, overwrite = tibble(bad = 1)),
    "data must have all expected names"
  )
})

test_that("prepare_loanbook_for_matching correctly overwrites name", {
  overwrite <- overwrite_demo
  out <- prepare_loanbook_for_matching(loanbook_demo, overwrite_demo) %>%
    dplyr::filter(id %in% overwrite$id & level %in% overwrite$level) %>%
    dplyr::left_join(overwrite, by = c("id", "level"))

  expect_equal(out$name.x, out$name.y)
})

test_that("prepare_loanbook_for_matching correctly overwrites sector", {
  overwrite <- overwrite_demo
  out <- prepare_loanbook_for_matching(loanbook_demo, overwrite_demo) %>%
    dplyr::filter(id %in% overwrite$id & level %in% overwrite$level) %>%
    dplyr::left_join(overwrite, by = c("id", "level"))

  expect_equal(out$sector.x, out$sector.y)
})

test_that("prepare_ald_for_matching outputs the expected tibble", {
  out <- prepare_ald_for_matching(ald_demo)
  expect_is(out, "tbl_df")
  expect_named(out, c("name", "sector"))
})

test_that("prepare_ald_for_matching errors if data lacks a crucial column", {
  bad_data <- ald_demo %>%
    dplyr::select(-sector)

  expect_error(
    prepare_ald_for_matching(bad_data),
    "data must have all expected names"
  )
})
