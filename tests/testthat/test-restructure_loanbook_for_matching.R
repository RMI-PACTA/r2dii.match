library(r2dii.dataraw)

test_that("restructure_loanbook_for_matching warns overwriting id_ vars", {
  expect_message(
    restructure_loanbook_for_matching(loanbook_demo),
    "Uniquifying.*id_direct_loantaker"
  )

  expect_message(
    restructure_loanbook_for_matching(loanbook_demo),
    "Uniquifying.*id_ultimate_parent"
  )
})

test_that("restructure_loanbook_for_matching cals uniquify_id_column()", {
  lbk <- loanbook_demo %>%
    uniquify_id_column(id_column = "id_direct_loantaker", prefix = "UP") %>%
    uniquify_id_column(id_column = "id_ultimate_parent", prefix = "UP")

  expect_equal(
    restructure_loanbook_for_matching(loanbook_demo),
    restructure_loanbook_for_matching(lbk)
  )
})

test_that("restructure_loanbook_for_matching may input bridge_sector(data)", {
  expect_warning(
    out <- restructure_loanbook_for_matching(bridge_sector(loanbook_demo)),
    "Using existing columns `sector` and `borderline`."
  )

  expect_equal(out, restructure_loanbook_for_matching(loanbook_demo))
})

test_that("restructure_loanbook_for_matching errors gracefully with bad input", {
  expect_error(
    restructure_loanbook_for_matching("bad"),
    "data.frame.*is not TRUE"
  )

  expect_error(
    restructure_loanbook_for_matching(loanbook_demo, overwrite = "bad"),
    "data.frame.*is not TRUE"
  )
})

test_that("restructure_loanbook_for_matching", {
  out <- restructure_loanbook_for_matching(loanbook_demo)
  expect_false(any(duplicated(out$id)))
})

test_that("restructure_loanbook_for_matching outputs a tibble with expected names", {
  out <- restructure_loanbook_for_matching(loanbook_demo)
  expect_is(out, "tbl_df")
  expect_named(
    out,
    c("level", "id", "name", "sector", "source", "alias")
  )

  out2 <- restructure_loanbook_for_matching(loanbook_demo, overwrite_demo)
  expect_is(out2, "tbl_df")
  expect_named(
    out2,
    c("level", "id", "name", "sector", "source", "alias")
  )
})

test_that("restructure_loanbook_for_matching errors with bad overwrite columns", {
  expect_error(
    restructure_loanbook_for_matching(loanbook_demo, overwrite = tibble(bad = 1)),
    "data must have all expected names"
  )
})

test_that("restructure_loanbook_for_matching correctly overwrites name", {
  overwrite <- overwrite_demo
  out <- restructure_loanbook_for_matching(loanbook_demo, overwrite_demo) %>%
    filter(id %in% overwrite$id & level %in% overwrite$level) %>%
    left_join(overwrite, by = c("id", "level"))

  expect_equal(out$name.x, out$name.y)
})

test_that("restructure_loanbook_for_matching correctly overwrites sector", {
  overwrite <- overwrite_demo
  out <- restructure_loanbook_for_matching(loanbook_demo, overwrite_demo) %>%
    filter(id %in% overwrite$id & level %in% overwrite$level) %>%
    left_join(overwrite, by = c("id", "level"))

  expect_equal(out$sector.x, out$sector.y)
})

test_that("restructure_ald_for_matching outputs the expected tibble", {
  out <- restructure_ald_for_matching(ald_demo)
  expect_is(out, "tbl_df")
  expect_named(out, c("name", "sector", "alias"))
})

test_that("restructure_ald_for_matching errors if data lacks a crucial column", {
  bad_data <- ald_demo %>%
    select(-sector)

  expect_error(
    restructure_ald_for_matching(bad_data),
    "data must have all expected names"
  )
})
