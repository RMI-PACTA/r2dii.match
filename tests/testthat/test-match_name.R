library(dplyr)
library(r2dii.data)

test_that("w/ non-NA only at intermediate level yields matches at intermediate
          level only", {
  lbk <- tibble::tibble(
    id_intermediate_parent_999 = "IP8",
    name_intermediate_parent_999 = "Nanco Hosiery Mills",

    id_ultimate_parent = NA_character_,
    name_ultimate_parent = NA_character_,

    id_direct_loantaker = NA_character_,
    name_direct_loantaker = NA_character_,

    sector_classification_system = "NACE",
    sector_classification_direct_loantaker = 3511,
  )

  ald <- tibble(
    name_company = c("nanco hosiery mills", "standard solar inc"),
    sector = c("power", "power"),
    alias_ald = c("nancohosierymills", "standardsolar inc")
  )

  out <- match_name(lbk, ald)
  expect_equal(out$level, "intermediate_parent_999")
})

test_that("w/ missing values at all levels outputs 0-row", {
  lbk <- tibble(
    id_direct_loantaker = NA_character_,
    name_direct_loantaker = NA_character_,
    id_ultimate_parent = NA_character_,
    name_ultimate_parent = NA_character_,
    sector_classification_system = "NACE",
    sector_classification_direct_loantaker = 291,
  )

  ald <- tibble(
    name_company = "any",
    sector = "power",
    alias_ald = "any",
  )

  out <- expect_warning(match_name(lbk, ald), "no match")
  expect_equal(nrow(out), 0L)
})

test_that("w/ 1 lbk row matching 1 ald company in 2 sectors outputs 2 rows", {
  sector_ald <- c("automotive", "shipping")

  lbk <- tibble(
    id_direct_loantaker = "C196",
    name_direct_loantaker = "Suzuki Motor Corp",
    sector_classification_system = "NACE",
    sector_classification_direct_loantaker = 291,

    id_ultimate_parent = NA_character_,
    name_ultimate_parent = NA_character_,
  )

  ald <- tibble(
    name_company = "suzuki motor corp",
    sector = sector_ald,
    alias_ald = "suzukimotor corp",
  )

  out <- match_name(lbk, ald, by_sector = FALSE)
  expect_equal(nrow(out), 2L)
  out$sector
  expect_equal(out$sector_ald, sector_ald)
})

test_that("`by_sector = TRUE` yields only matching sectors", {
  out <- match_name(
    fake_lbk(),
    fake_ald(),
    by_sector = TRUE
  ) %>%
    filter(sector != sector_ald)

  expect_equal(nrow(out), 0L)
})

test_that("w/ mismatching sector_classification and `by_sector = TRUE` yields
          no match", {
  # Lookup code to sectors via r2dii.data::sector_classifications$code
  code_for_sector_power <- 27
  sector_not_power <- "coal"

  expect_warning(
    out <- match_name(
      fake_lbk(sector_classification_direct_loantaker = code_for_sector_power),
      fake_ald(sector = sector_not_power),
      by_sector = TRUE
    ),
    "no match"
  )
  expect_equal(nrow(out), 0L)
})

test_that("w/ row 1 of loanbook and crucial cols yields expected", {
  expected <- tibble(
    sector_classification_system = "NACE",
    id_ultimate_parent = "UP15",
    name_ultimate_parent = "Alpine Knits India Pvt. Limited",
    id_direct_loantaker = "C294",
    name_direct_loantaker = "Yuamen Xinneng Thermal Power Co Ltd",
    sector_classification_direct_loantaker = 3511,
    id_2dii = "UP1",
    level = "ultimate_parent",
    sector = "power",
    sector_ald = "power",
    name = "Alpine Knits India Pvt. Limited",
    name_ald = "alpine knits india pvt. limited",
    score = 1,
    source = "loanbook"
  )

  expect_equal(
    match_name(fake_lbk(), fake_ald()),
    expected
  )
})

expect_names_match_name <- c(
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

  "id_2dii",
  "level",
  "sector",
  "sector_ald",
  "name",
  "name_ald",
  "score",
  "source"
)

test_that("w/ 1 row of full loanbook_demo yields expected names", {
  out <- match_name(slice(loanbook_demo, 1L), fake_ald())
  expect_named(out, expect_names_match_name)
})

test_that("takes unprepared loanbook and ald datasets", {
  expect_no_error(match_name(slice(loanbook_demo, 1), ald_demo))
})

test_that("w/ loanbook that matches nothing, yields expected", {
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
    expect_names_match_name
  )
  expect_false(any(c("alias", "alias_ald") %in% names(out)))
})

test_that("w/ 2 lbk rows matching 2 ald rows, yields expected names", {
  # Slice 5 once was problematic (#85)
  lbk45 <- slice(loanbook_demo, 4:5)
  expect_named(
    match_name(lbk45, ald_demo),
    expect_names_match_name
  )
})

test_that("w/ 1 lbk row matching ultimate, yields expected names", {
  lbk1 <- slice(loanbook_demo, 1)

  expect_named(
    match_name(lbk1, ald_demo),
    expect_names_match_name
  )
})

test_that("takes `min_score`", {
  expect_no_error(
    match_name(slice(loanbook_demo, 1), ald_demo, min_score = 0.5)
  )
})

test_that("takes `method`", {
  expect_false(
    identical(
      match_name(slice(loanbook_demo, 4:15), ald_demo, method = "jw"),
      match_name(slice(loanbook_demo, 4:15), ald_demo, method = "osa")
    )
  )
})

test_that("takes `p`", {
  lbk45 <- slice(loanbook_demo, 4:5) # slice(., 1) seems insensitive to `p`

  expect_false(
    identical(
      match_name(lbk45, ald_demo, p = 0.1),
      match_name(lbk45, ald_demo, p = 0.2)
    )
  )
})

test_that("takes `overwrite`", {
  lbk <- slice(loanbook_demo, 4:25)

  expect_false(
    identical(
      match_name(lbk, ald_demo, overwrite = NULL),
      suppressWarnings(match_name(lbk, ald_demo, overwrite = overwrite_demo))
    )
  )
})

test_that("warns overwrite", {
  expect_warning(
    match_name(fake_lbk(), fake_ald(), overwrite = overwrite_demo)
  )

  verify_output(
    test_path("output", "match_name-overwrite_warning.txt"),
    as.data.frame(
      match_name(fake_lbk(), fake_ald(), overwrite = overwrite_demo)
    )
  )
})

test_that("recovers `sector_lbk`", {
  expect_true(
    rlang::has_name(
      match_name(slice(loanbook_demo, 1), ald_demo),
      "sector"
    )
  )
})

test_that("recovers `sector_ald`", {
  expect_true(
    rlang::has_name(match_name(loanbook_demo, ald_demo), "sector_ald")
  )
})

test_that("outputs name from loanbook, not name.y (bug fix)", {
  out <- match_name(slice(loanbook_demo, 1), ald_demo)
  expect_false(has_name(out, "name.y"))
})

test_that("works with `min_score = 0` (bug fix)", {
  expect_no_error(match_name(slice(loanbook_demo, 1), ald_demo, min_score = 0))
})

test_that("outputs only perfect matches if any (#40 @2diiKlaus)", {
  this_name <- "Nanaimo Forest Products Ltd."
  this_alias <- to_alias(this_name)
  this_lbk <- loanbook_demo %>%
    filter(name_direct_loantaker == this_name)

  nanimo_scores <- this_lbk %>%
    match_name(ald_demo) %>%
    mutate(alias = to_alias(name)) %>%
    filter(alias == this_alias) %>%
    pull(score)

  expect_true(
    any(nanimo_scores == 1)
  )
  expect_true(
    all(nanimo_scores == 1)
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

test_that("preserves groups", {
  grouped_loanbook <- slice(loanbook_demo, 1) %>%
    group_by(id_loan)

  expect_true(is_grouped_df(match_name(grouped_loanbook, ald_demo)))
})

test_that("outputs id consistent with level", {
  out <- slice(loanbook_demo, 5) %>% match_name(ald_demo)
  expect_equal(out$level, c("direct_loantaker", "ultimate_parent"))
  expect_equal(out$id_2dii, c("DL1", "UP1"))
})

test_that("no longer yiels all NAs in lbk columns (#85 @jdhoffa)", {
  out <- match_name(loanbook_demo, ald_demo)
  out_lbk_cols <- out %>%
    select(
      setdiff(
        names(.),
        names_added_by_match_name()
      )
    )

  all_lbk_col_have_na_only <- out_lbk_cols %>%
    purrr::map_lgl(~ all(is.na(.x))) %>%
    all()

  expect_false(all_lbk_col_have_na_only)
})

test_that("handles any number of intermediate_parent columns (#84)", {
  # name_level is identical for all levels. I expect them all in the output
  name_level <- "Alpine Knits India Pvt. Limited"

  lbk_mini <- tibble::tibble(
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

  out <- match_name(lbk_mini, fake_ald())
  output_levels <- unique(out$level)
  expect_length(output_levels, 5L)

  has_intermediate_parent <- any(grepl("intermediate_parent_1", output_levels))
  expect_true(has_intermediate_parent)
})

test_that("warns/errors if some/all system classification is unknown", {
  some_bad_system <- fake_lbk(sector_classification_system = c("NACE", "bad"))

  expect_warning(
    class = "some_sec_classif_unknown",
    match_name(some_bad_system, fake_ald())
  )

  all_bad_system <- fake_lbk(sector_classification_system = c("bad", "bad"))

  expect_error(
    class = "all_sec_classif_unknown",
    match_name(all_bad_system, fake_ald())
  )

  bad <- -999
  some_bad_code <- fake_lbk(sector_classification_direct_loantaker = c(35, bad))

  expect_warning(
    class = "some_sec_classif_unknown",
    match_name(some_bad_code, fake_ald()),
  )

  all_bad_code <- fake_lbk(sector_classification_direct_loantaker = c(bad, bad))

  expect_error(
    class = "all_sec_classif_unknown",
    match_name(all_bad_code, fake_ald()),
  )
  # styler: off
  verify_output(
    test_path("output", "match_name-sec_classif_unknown.txt"), {
      "# Error"
      match_name(all_bad_code, fake_ald())

      match_name(all_bad_system, fake_ald())

      "# Warning"
      invisible(match_name(some_bad_code, fake_ald()))

      invisible(match_name(some_bad_system, fake_ald()))
    }
  )
  # styler: on
})

# crucial names -----------------------------------------------------------

test_that("w/ loanbook or ald with missing names errors gracefully", {
  invalid <- function(data, x) dplyr::rename(data, bad = x)

  expect_error_missing_names <- function(lbk = NULL, ald = NULL) {
    expect_error(
      class = "missing_names",
      match_name(lbk %||% fake_lbk(), ald %||% fake_ald())
    )
  }

  expect_error_missing_names(ald = invalid(fake_ald(), "sector"))

  expect_error_missing_names(invalid(fake_lbk(), "name_ultimate_parent"))
  expect_error_missing_names(invalid(fake_lbk(), "id_ultimate_parent"))
  expect_error_missing_names(invalid(fake_lbk(), "id_direct_loantaker"))
  expect_error_missing_names(invalid(fake_lbk(), "name_direct_loantaker"))

  expect_error_missing_names(
    invalid(fake_lbk(), "sector_classification_system")
  )
  expect_error_missing_names(
    invalid(fake_lbk(), "sector_classification_direct_loantaker")
  )

  expect_error_missing_names(
    match_name(
      # missing name_intermediate_parent (doesn't come with fake_lbk())
      fake_lbk(id_intermediate_parent = id_direct_loantaker),
      fake_ald()
    )
  )
})

test_that("w/ lbk with name_intermediate_* but missing id_intermediate_*", {
  expect_error(
    match_name(
      class = "has_name_but_not_id",
      # missing id_intermediate_parent (doesn't come with fake_lbk())
      fake_lbk(name_intermediate_parent = name_direct_loantaker),
      fake_ald()
    )
  )
})

test_that("w/ overwrite with missing names errors gracefully", {
  expect_error(
    class = "missing_names",
    match_name(
      fake_lbk(),
      overwrite = tibble(bad = 1),
      fake_ald()
    )
  )
})

test_that("with bad input errors gracefully", {
  bad_loanbook <- loanbook_demo %>%
    mutate(name_direct_loantaker = as.numeric(12))

  expect_no_error(match_name(bad_loanbook, ald_demo))
})

test_that("with name_intermediate but not id_intermediate throws an error", {
  expect_error(
    class = "has_name_but_not_id",
    match_name(fake_lbk(name_intermediate_parent = "a"), fake_ald())
  )
})

test_that("0-row output has expected column type", {
  lbk <- slice(loanbook_demo, 2)
  out <- expect_warning(match_name(lbk, ald_demo), "no match")

  lbk_types <- purrr::map_chr(lbk, typeof)
  out_types <- purrr::map_chr(out, typeof)

  same <- intersect(names(out_types), names(lbk_types))
  expect_identical(lbk_types[same], out_types[same])
})

test_that("with loanbook_demo and ald_demo outputs known output", {
  out <- arrange(match_name(loanbook_demo, ald_demo), across())
  expect_known_value(out, "ref-match-name", update = FALSE)
  # More informative when it fails
  expect_equal(out, readRDS(test_path("ref-match-name")))
})

test_that("w/ mismatching sector_classification and `by_sector = FALSE` yields
          a match", {
  # Lookup code to sectors via r2dii.data::sector_classifications$code
  code_for_sector_power <- 27
  sector_not_power <- "coal"

  out <- match_name(
    fake_lbk(sector_classification_direct_loantaker = code_for_sector_power),
    fake_ald(sector = sector_not_power),
    by_sector = FALSE
  )
  expect_equal(nrow(out), 1L)
})

test_that("takes `by_sector`", {
  slice(loanbook_demo, 4:15)
  expect_false(
    identical(
      match_name(slice(loanbook_demo, 4:15), ald_demo, by_sector = TRUE),
      match_name(slice(loanbook_demo, 4:15), ald_demo, by_sector = FALSE)
    )
  )
})

test_that("w/ duplicates in ald throws now error; instead remove duplicates", {
  dupl <- rbind(fake_ald(), fake_ald())
  expect_error(out <- match_name(fake_lbk(), dupl), NA)
  expect_equal(nrow(out), 1L)
})
