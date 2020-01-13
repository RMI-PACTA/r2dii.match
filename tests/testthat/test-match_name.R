library(dplyr)
library(r2dii.dataraw)

expected_names_of_match_name_with_loanbook_demo <- c(
  "id_loan",

  "id_direct_loantaker",
  "name_direct_loantaker",

  "id_intermediate_parent_1",
  "name_intermediate_parent_1",

  "id_ultimate_parent",
  "name_ultimate_parent",

  "loan_size_outstanding",
  "loan_size_outstanding_currency",
  "loan_size_credit_limit",
  "loan_size_credit_limit_currency",

  "sector_classification_system",
  "sector_classification_input_type",
  "sector_classification_direct_loantaker",

  "fi_type",
  "flag_project_finance_loan",
  "name_project",

  "lei_direct_loantaker",
  "isin_direct_loantaker",

  "id",
  "level",
  "sector",
  "sector_ald",
  "name",
  "name_ald",
  "alias_lbk",
  "alias_ald",
  "score",
  "source"
)

test_that("match_name w/ row 1 of loanbook and crucial cols yields expected", {
  # loanbook_demo %>% mini_lbk(1) %>% dput()
  lbk_mini1 <- tibble::tibble(
    id_ultimate_parent = "UP15",
    name_ultimate_parent = "Alpine Knits India Pvt. Limited",
    id_direct_loantaker = "C294",
    name_direct_loantaker = "Yuamen Xinneng Thermal Power Co Ltd",
    sector_classification_system = "NACE",
    sector_classification_direct_loantaker = 3511
  )

  # loanbook_demo %>% mini_lbk(1) %>% mini_ald() %>% dput()
  ald_mini <- tibble::tibble(
    name_company = "alpine knits india pvt. limited",
    sector = "power",
    alias_ald = "alpineknitsindiapvt ltd"
  )

  # out %>% dput()
  expected <- tibble(
    id_ultimate_parent = "UP15",
    name_ultimate_parent = "Alpine Knits India Pvt. Limited",
    id_direct_loantaker = "C294",
    name_direct_loantaker = "Yuamen Xinneng Thermal Power Co Ltd",
    sector_classification_system = "NACE",
    sector_classification_direct_loantaker = 3511,
    id = "UP1",
    level = "ultimate_parent",
    sector = "power",
    sector_ald = "power",
    name = "Alpine Knits India Pvt. Limited",
    name_ald = "alpine knits india pvt. limited",
    alias_lbk = "alpineknitsindiapvt ltd",
    alias_ald = "alpineknitsindiapvt ltd",
    score = 1,
    source = "loanbook"
  )
  out <- match_name(lbk_mini1, ald_mini)

  expect_equal(out, expected)
})

test_that("match_name w/ 1 row of full loanbook_demo yields expected names", {
  # loanbook_demo %>% mini_lbk(1) %>% mini_ald() %>% dput()
  ald_mini <- tibble::tibble(
    name_company = "alpine knits india pvt. limited",
    sector = "power",
    alias_ald = "alpineknitsindiapvt ltd"
  )

  out <- loanbook_demo %>%
    slice(1) %>%
    match_name(ald_mini)

  # setdiff(names(out), expected_names_of_match_name_with_loanbook_demo)
  expect_named(out, expected_names_of_match_name_with_loanbook_demo)
})

test_that("match_name takes unprepared loanbook and ald datasets", {
  expect_error(
    match_name(slice(loanbook_demo, 1), ald_demo),
    NA
  )
})

test_that("match_name takes `min_score`", {
  expect_error(
    match_name(slice(loanbook_demo, 1), ald_demo, min_score = 0.5),
    NA
  )
})

test_that("match_name takes `by_sector`", {
  expect_false(
    identical(
      match_name(slice(loanbook_demo, 4:15), ald_demo, by_sector = TRUE),
      match_name(slice(loanbook_demo, 4:15), ald_demo, by_sector = FALSE)
    )
  )
})

test_that("match_name takes `method`", {
  expect_false(
    identical(
      match_name(slice(loanbook_demo, 4:15), ald_demo, method = "jw"),
      match_name(slice(loanbook_demo, 4:15), ald_demo, method = "osa")
    )
  )
})

test_that("match_name takes `p`", {
  lbk45 <- slice(loanbook_demo, 4:5) # slice(., 1) seems insensitive to `p`

  expect_false(
    identical(
      match_name(lbk45, ald_demo, p = 0.1),
      match_name(lbk45, ald_demo, p = 0.2)
    )
  )
})

test_that("match_name takes `overwrite`", {
  expect_false(
    identical(
      match_name(slice(loanbook_demo, 4:25), ald_demo, overwrite = NULL),
      match_name(slice(loanbook_demo, 4:25), ald_demo, overwrite = overwrite_demo)
    )
  )
})

test_that("match_name recovers `sector_lbk`", {
  expect_true(
    rlang::has_name(
      match_name(slice(loanbook_demo, 1), ald_demo),
      "sector"
    )
  )
})

test_that("match_name recovers `sector_ald`", {
  expect_true(
    rlang::has_name(match_name(loanbook_demo, ald_demo), "sector_ald")
  )
})

test_that("match_name outputs name from loanbook, not name.y (bug fix)", {
  out <- match_name(slice(loanbook_demo, 1), ald_demo)
  expect_false(has_name(out, "name.y"))
})

test_that("match_name works with `min_score = 0` (bug fix)", {
  expect_error(
    match_name(slice(loanbook_demo, 1), ald_demo, min_score = 0),
    NA
  )
})

test_that("match_name outputs only perfect matches if any (#40 @2diiKlaus)", {
  this_name <- "Nanaimo Forest Products Ltd."
  this_alias <- to_alias(this_name)
  this_lbk <- loanbook_demo %>%
    filter(name_direct_loantaker == this_name)

  nanimo_scores <- this_lbk %>%
    match_name(ald_demo) %>%
    filter(alias_lbk == this_alias) %>%
    pull(score)

  expect_true(
    any(nanimo_scores == 1)
  )
  expect_true(
    all(nanimo_scores == 1)
  )
})

test_that("prefer_perfect_match_by prefers score == 1 if `var` group has any", {
  # styler: off
  data <- tribble(
    ~var,  ~score,
        1,      1,
        2,      1,
        2,   0.99,
        3,   0.99,
  )
  # styler: on

  expect_equal(
    prefer_perfect_match_by(data, var),
    tibble(var = c(1, 2, 3), score = c(1, 1, 0.99))
  )
})

test_that("match_name()$level lacks prefix 'name_' suffix '_lbk'", {
  out <- match_name(slice(loanbook_demo, 1), ald_demo)
  expect_false(
    any(startsWith(unique(out$level), "name_"))
  )
  expect_false(
    any(endsWith(unique(out$level), "_lbk"))
  )
})

test_that("match_name preserves groups", {
  grouped_loanbook <- slice(loanbook_demo, 1) %>%
    group_by(id_loan)

  expect_true(is_grouped_df(match_name(grouped_loanbook, ald_demo)))
})

test_that("match_name outputs id consistent with level", {
  out <- slice(loanbook_demo, 5) %>% match_name(ald_demo)
  expect_equal(out$level, c("ultimate_parent", "direct_loantaker"))
  expect_equal(out$id, c("UP1", "DL1"))
})

test_that("match_name no longer yiels all NAs in lbk columns (#85 @jdhoffa)", {
  out <- match_name(loanbook_demo, ald_demo)
  out_lbk_cols <- out %>%
    select(
      setdiff(
        names(.),
        names_added_by_match_name()
      )
    )

  all_lbk_columns_contain_na_exclusively <- out_lbk_cols %>%
    purrr::map_lgl(~ all(is.na(.x))) %>%
    all()

  expect_false(all_lbk_columns_contain_na_exclusively)
})

test_that("match_name w/ loanbook that matches nothing, yields expected", {
  # Matches cero row ...
  lbk2 <- slice(loanbook_demo, 2)
  expect_warning(
    out <- match_name(lbk2, ald_demo),
    "no match"
  )
  expect_equal(nrow(out), 0L)
  # ... but preserves minimum expected names
  expect_named(
    out,
    expected_names_of_match_name_with_loanbook_demo
  )
})

test_that("match_name w/ 2 lbk rows matching 2 ald rows, yields expected names", {
  # Slice 5 once was problematic (#85)
  lbk45 <- slice(loanbook_demo, 4:5)
  expect_named(
    match_name(lbk45, ald_demo),
    expected_names_of_match_name_with_loanbook_demo
  )
})

test_that("match_name w/ 1 lbk row matching ultimate, yields expected names", {
  # Slice 1 used to fail due to poorly handled levels
  lbk1 <- slice(loanbook_demo, 1)

  expect_named(
    match_name(lbk1, ald_demo),
    expected_names_of_match_name_with_loanbook_demo
  )
})

test_that("match_name handles any number if intermediate_parent columns (#84)", {
  # name_level is identical for all levels. I expect them all in the output
  name_level <- "Alpine Knits India Pvt. Limited"

  lbk_mini <- tibble::tibble(
    # Same name
    name_intermediate_parent_1 = name_level,
    name_intermediate_parent_2 = name_level,
    name_intermediate_parent_n = name_level,
    name_direct_loantaker = name_level,
    name_ultimate_parent = name_level,

    id_intermediate_parent_1 = "IP1",
    id_intermediate_parent_2 = "IP2",
    id_intermediate_parent_n = "IPn",
    id_direct_loantaker = "DL1",
    id_ultimate_parent = "UP1",

    sector_classification_system = "NACE",
    sector_classification_direct_loantaker = 3511
  )

  # lbk_mini1 %>% mini_ald() %>% dput()
  ald_mini <- tibble::tibble(
    name_company = "alpine knits india pvt. limited",
    sector = "power",
    alias_ald = "alpineknitsindiapvt ltd"
  )

  out <- match_name(lbk_mini, ald_mini)
  output_levels <- unique(out$level)
  expect_length(output_levels, 5L)

  has_intermediate_parent <- any(grepl("intermediate_parent_1", output_levels))
  expect_true(has_intermediate_parent)
})

