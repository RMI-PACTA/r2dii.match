library(r2dii.dataraw)

loanbook_rowid <- loanbook_demo %>%
  tibble::rowid_to_column()

test_that("restructure_loanbook_for_matching warns overwriting id_ vars", {
  expect_message(
    restructure_loanbook_for_matching(loanbook_rowid),
    "Uniquifying.*id_direct_loantaker"
  )

  expect_message(
    restructure_loanbook_for_matching(loanbook_rowid),
    "Uniquifying.*id_ultimate_parent"
  )
})

test_that("restructure_loanbook_for_matching cals uniquify_id_column()", {
  lbk <- loanbook_rowid %>%
    uniquify_id_column(id_column = "id_direct_loantaker", prefix = "UP") %>%
    uniquify_id_column(id_column = "id_ultimate_parent", prefix = "UP")

  expect_equal(
    restructure_loanbook_for_matching(loanbook_rowid),
    restructure_loanbook_for_matching(lbk)
  )
})

test_that("restructure_loanbook_for_matching may input add_sector_and_borderline(data)", {
  expect_warning(
    out <- restructure_loanbook_for_matching(add_sector_and_borderline(loanbook_rowid)),
    "Using existing columns `sector` and `borderline`."
  )

  expect_equal(out, restructure_loanbook_for_matching(loanbook_rowid))
})

test_that("restructure_loanbook_for_matching errors gracefully with bad input", {
  expect_error(
    restructure_loanbook_for_matching("bad"),
    "data.frame.*is not TRUE"
  )

  expect_error(
    restructure_loanbook_for_matching(loanbook_rowid, overwrite = "bad"),
    "data.frame.*is not TRUE"
  )
})

test_that("restructure_loanbook_for_matching outputs a tibble with expected names", {
  out <- restructure_loanbook_for_matching(loanbook_rowid)
  expect_is(out, "tbl_df")
  expect_named(
    out,
    c("rowid", "level", "id", "name", "sector", "source", "alias")
  )

  out2 <- restructure_loanbook_for_matching(loanbook_rowid, overwrite_demo)
  expect_is(out2, "tbl_df")
  expect_named(
    out2,
    c("rowid", "level", "id", "name", "sector", "source", "alias")
  )
})

test_that("restructure_loanbook_for_matching errors with bad overwrite columns", {
  expect_error(
    restructure_loanbook_for_matching(loanbook_rowid, overwrite = tibble(bad = 1)),
    "data must have all expected names"
  )
})

test_that("restructure_loanbook_for_matching correctly overwrites name", {
  overwrite <- overwrite_demo
  out <- restructure_loanbook_for_matching(loanbook_rowid, overwrite_demo) %>%
    filter(id %in% overwrite$id & level %in% overwrite$level) %>%
    left_join(overwrite, by = c("id", "level"))

  expect_equal(out$name.x, out$name.y)
})

test_that("restructure_loanbook_for_matching correctly overwrites sector", {
  overwrite <- overwrite_demo
  out <- restructure_loanbook_for_matching(loanbook_rowid, overwrite_demo) %>%
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
