library(dplyr, warn.conflicts = FALSE)
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

  expect_warning(out <- match_name(lbk, ald), "no match")
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
    source = "loanbook",
    borderline = TRUE
  )

  if (packageVersion("r2dii.data") > "0.1.4") expected$borderline <- FALSE

  expect_equal(
    match_name(fake_lbk(), fake_ald()),
    expected
  )
})

test_that("w/ 1 row of full loanbook_demo yields expected names", {
  out <- match_name(slice(loanbook_demo, 1L), fake_ald())
  expect_equal(names(out), expect_names_match_name)
})

test_that("takes unprepared loanbook and ald datasets", {
  expect_no_error(match_name(slice(loanbook_demo, 1), ald_demo))
})

test_that("w/ loanbook that matches nothing, yields expected", {
  # Matches zero row ...
  lbk2 <- slice(loanbook_demo, 2)
  expect_warning(
    out <- match_name(lbk2, ald_demo),
    "no match"
  )
  expect_equal(nrow(out), 0L)
  # ... but preserves minimum expected names
  expect_equal(
    names(out),
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

  expect_snapshot(
    match_name(fake_lbk(), fake_ald(), overwrite = overwrite_demo)
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

  suppressWarnings(
    # In this expectation, we only care about this specific warning
    expect_warning(
      class = "some_sec_classif_unknown",
      match_name(some_bad_code, fake_ald())
    )
  )

  all_bad_code <- fake_lbk(sector_classification_direct_loantaker = c(bad, bad))

  expect_error(
    class = "all_sec_classif_unknown",
    match_name(all_bad_code, fake_ald()),
  )
})

# crucial names -----------------------------------------------------------

test_that("w/ loanbook or ald with missing names errors gracefully", {
  invalid <- function(data, x) dplyr::rename(data, bad = all_of_(x))

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

test_that("works with UP266", {
  up266 <- filter(loanbook_demo, id_ultimate_parent == "UP266")
  out <- match_name(up266, ald_demo)

  prefix <- c(glue("id_{level()}"), glue("name_{level()}"))
  prefix <- paste0(prefix, collapse = "|")

  expect_snapshot(select(out, .data$id_2dii, matches(prefix)))
})

test_that("with loanbook_demo and ald_demo outputs expected value", {
  skip_on_ci()
  out <- match_name(loanbook_demo, ald_demo)
  expect_snapshot_value(round_dbl(out), style = "json2")
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

test_that("throws an error if the `loanbook` has reserved columns", {
  alias <- mutate(fake_lbk(), alias = "bla")
  expect_error(
    class = "reserved_column",
    match_name(alias, fake_ald()),
    regexp = "alias"
  )

  sector <- mutate(fake_lbk(), sector = "auto")
  expect_error(
    class = "reserved_column",
    match_name(sector, fake_ald()),
    regexp = "sector"
  )

  rowid <- mutate(fake_lbk(), rowid = 1L)
  expect_error(
    class = "reserved_column",
    match_name(rowid, fake_ald()),
    regexp = "rowid"
  )

  rowid_sector <- mutate(fake_lbk(), rowid = 1L, sector = "auto")
  expect_error(
    class = "reserved_column",
    match_name(rowid_sector, fake_ald()),
    regexp = "rowid.*sector"
  )

  sector_rowid <- mutate(fake_lbk(), sector = "auto", rowid = 1L)
  expect_error(
    class = "reserved_column",
    match_name(sector_rowid, fake_ald()),
    regexp = "rowid.*sector"
  )
})

test_that("outputs correct `borderline` (#269)", {
  # This sector-code matches the 2DII sector "coal" fully.
  border_false <- 21000
  coal_2dii <- "coal"
  # This sector-code matches the 2DII sector "power" as "borderline".
  border_true <- 36100
  power_2dii <- "power"
  # Confirm with:
  # filter(sector_classifications, code %in% c(border_false, border_true))

  a_code_system <- "SIC"
  some_ids <- c(1, 2)
  some_companies <- c("a", "b")

  lbk <- fake_lbk(
    id_loan = some_ids,
    sector_classification_system = a_code_system,
    id_direct_loantaker = some_ids,
    name_direct_loantaker = some_companies,
    sector_classification_direct_loantaker = c(border_false, border_true)
  )

  ald <- fake_ald(
    name_company = some_companies,
    sector = c(coal_2dii, power_2dii)
  )

  out <- match_name(lbk, ald)
  expect_equal(out$borderline, c(FALSE, TRUE))
})

test_that("matches any case of ald$sector, but converts sector to lowercase", {
  low <- match_name(fake_lbk(), fake_ald(sector = "power"))
  expect_equal(low$sector, "power")

  upp <- match_name(fake_lbk(), fake_ald(sector = "POWER"))
  # The original uppercase is converted to lowercase
  expect_equal(upp$sector, "power")

  # The output is identical
  expect_identical(low, upp)
})

test_that("matches any case of ald$name_company, but preserves original case", {
  low <- match_name(fake_lbk(), fake_ald(name_company = "alpine knits"))
  expect_equal(nrow(low), 1L)
  expect_equal(low$name_ald, "alpine knits")

  upp <- match_name(fake_lbk(), fake_ald(name_company = "ALPINE KNITS"))
  expect_equal(nrow(upp), 1L)
  # The original uppercase is preserved
  expect_equal(upp$name_ald, "ALPINE KNITS")
})

test_that("with arguments passed via ellipsis, throws no error (#310)", {
  # `q` isn't a formal argument of `match_name()`
  expect_false(any(grepl("^q$", names(formals(match_name)))))

  # `q` should pass `...` with no error
  expect_no_error(match_name(fake_lbk(), fake_ald(), method = "qgram", q = 1))
})

test_that("with arguments passed via ellipsis, outputs the expected score", {
  lbk <-
    fake_lbk(name_direct_loantaker = "Yuamen Changyuan Hydropower Co., Ltd.")
  ald <-
    fake_ald(name_company = "yiyang baoyuan power generation co., ltd.")

  this_q <- 0.5
  expected1 <- stringdist::stringsim(
    to_alias(lbk$name_direct_loantaker),
    to_alias(ald$name_company),
    method = "qgram", q = this_q
  )

  out1 <- match_name(lbk, ald, method = "qgram", q = this_q)
  expect_equal(unique(out1$score), expected1)

  this_q <- 1
  expected2 <- stringdist::stringsim(
    to_alias(lbk$name_direct_loantaker),
    to_alias(ald$name_company),
    method = "qgram", q = this_q
  )

  # Ensure this test does not just duplicate the previous one
  expect_false(identical(expected1, expected2))

  out2 <- match_name(lbk, ald, method = "qgram", q = this_q)
  expect_equal(unique(out2$score), expected2)
})

test_that("with relevant options allows loanbook with reserved columns", {
  restore <- options(r2dii.match.allow_reserved_columns = TRUE)
  on.exit(options(restore), add = TRUE)

  lbk <- mutate(fake_lbk(), sector = "a", borderline = FALSE)
  expect_no_error(
    # Don't warn if found no match
    suppressWarnings(match_name(lbk, fake_ald()))
  )
})

test_that("w/ loanbook w/ reserved cols, outputs sector not i.sector (#330)", {
  restore <- options(r2dii.match.allow_reserved_columns = TRUE)
  on.exit(options(restore), add = TRUE)

  reserved <- mutate(fake_lbk(), sector = "power", borderline = FALSE)
  out <- match_name(reserved, fake_ald())

  expect_true(utils::hasName(out, "sector"))
  expect_false(utils::hasName(out, "i.sector"))
})

test_that("w/ loanbook lacking sector or borderline, errors gracefully (#330)", {
  restore <- options(r2dii.match.allow_reserved_columns = TRUE)
  on.exit(options(restore), add = TRUE)

  lacks_borderline <- mutate(fake_lbk(), sector = "power")
  expect_error(
    match_name(lacks_borderline, fake_ald()),
    "Must have both `sector` and `borderline`"
  )

  lacks_sector <- mutate(fake_lbk(), borderline = TRUE)
  expect_error(
    match_name(lacks_sector, fake_ald()),
    "Must have both `sector` and `borderline`"
  )
})

test_that("errors if any id_loan is duplicated (#349)", {
  duplicated <- rep.int(1, times = 2)
  lbk <- fake_lbk(id_loan = duplicated)
  ald <- fake_ald()

  expect_snapshot_error(match_name(lbk, ald))
  expect_error(class = "duplicated_id_loan", match_name(lbk, ald))
})

test_that("allows custom `sector_classifications` via options() (#354)", {
  loanbook <- fake_lbk(sector_classification_system = "XYZ")
  ald <- fake_ald()
  custom_classification <- tibble::tribble(
    ~sector,       ~borderline,  ~code, ~code_system,
    "power",             FALSE, "3511",        "XYZ",
  )

  # Allow users to inject their own `sector_classifications`
  old <- options(r2dii.match.sector_classifications = custom_classification)
  out <- match_name(loanbook, ald)
  expect_equal(nrow(out), 1L)
  options(old)
})
