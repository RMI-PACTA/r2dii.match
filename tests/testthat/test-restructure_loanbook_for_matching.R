library(r2dii.data)

loanbook_rowid <- loanbook_demo %>%
  tibble::rowid_to_column()

test_that("warns overwriting id_ vars", {
  expect_message(
    restructure_loanbook_for_matching(loanbook_rowid),
    "Uniquifying.*id_direct_loantaker"
  )

  expect_message(
    restructure_loanbook_for_matching(loanbook_rowid),
    "Uniquifying.*id_ultimate_parent"
  )
})

test_that("may input add_sector_and_borderline(data)", {
  expect_warning(
    out <- restructure_loanbook_for_matching(
      add_sector_and_borderline(loanbook_rowid)
    ),
    "Using existing columns `sector` and `borderline`."
  )

  expect_equal(out, restructure_loanbook_for_matching(loanbook_rowid))
})

test_that("errors gracefully with bad input", {
  expect_error(
    restructure_loanbook_for_matching("bad"),
    "data.frame.*is not TRUE"
  )

  expect_error(
    restructure_loanbook_for_matching(loanbook_rowid, overwrite = "bad"),
    "data.frame.*is not TRUE"
  )
})

test_that("outputs a tibble with expected names", {
  out <- restructure_loanbook_for_matching(loanbook_rowid)
  expect_is(out, "tbl_df")
  expect_named(
    out,
    c("rowid", "level", "id_2dii", "name", "sector", "source", "alias")
  )
})

test_that("correctly overwrites name", {
  overwrite <- overwrite_demo

  out <- suppressWarnings(
    restructure_loanbook_for_matching(loanbook_rowid, overwrite)
  ) %>%
    filter(id_2dii %in% overwrite$id_2dii & level %in% overwrite$level) %>%
    left_join(overwrite, by = c("id_2dii", "level"))

  expect_equal(out$name.x, out$name.y)
})

test_that("correctly overwrites sector", {
  overwrite <- overwrite_demo

  out <- suppressWarnings(
    restructure_loanbook_for_matching(loanbook_rowid, overwrite)
  ) %>%
    filter(id_2dii %in% overwrite$id_2dii & level %in% overwrite$level) %>%
    left_join(overwrite, by = c("id_2dii", "level"))

  expect_equal(out$sector.x, out$sector.y)
})

test_that("restructure_ald_for_matching outputs the expected tibble", {
  out <- restructure_ald_for_matching(ald_demo)
  expect_is(out, "tbl_df")
  expect_named(out, c("name", "sector", "alias"))
})
