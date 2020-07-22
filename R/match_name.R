#' Match a loanbook and asset-level datasets (ald) by the `name_*` columns
#'
#' `match_name()` scores the match between names in a loanbook dataset (columns
#' can be `name_direct_loantaker`, `name_intermediate_parent*` and
#' `name_ultimate_parent`) with names in an asset-level dataset (column
#' `name_company`). The raw names are first internally transformed, and aliases
#' are assigned. The similarity between aliases in each of the loanbook and ald
#' datasets is scored using [stringdist::stringsim()].
#'
#' @template alias-assign
#' @template ignores-but-preserves-existing-groups
#'
#' @param loanbook,ald data frames structured like [r2dii.data::loanbook_demo]
#'   and [r2dii.data::ald_demo].
#' @param by_sector Should names only be compared if companies belong to the
#'   same `sector`?
#' @param min_score A number between 0-1, to set the minimum `score` threshold.
#'   A `score` of 1 is a perfect match.
#' @param method Method for distance calculation. One of `c("osa", "lv", "dl",
#'   "hamming", "lcs", "qgram", "cosine", "jaccard", "jw", "soundex")`. See
#'   [stringdist::stringdist-metrics].
#' @inheritParams stringdist::stringdist
#' @param overwrite A data frame used to overwrite the `sector` and/or `name`
#'   columns of a particular direct loantaker or ultimate parent. To overwrite
#'   only `sector`, the value in the `name` column should be `NA` and
#'   vice-versa. This file can be used to manually match loanbook companies to
#'   ald.
#'
#' @family user-oriented
#'
#' @return A data frame with the same groups (if any) and columns as `loanbook`,
#'   and the additional columns:
#'   * `id_2dii` - an id used internally by `match_name()` to distinguish
#'   companies
#'   * `level` - the level of granularity that the loan was matched at
#'   (e.g `direct_loantaker` or `ultimate_parent`)
#'   * `sector` - the sector of the `loanbook` company
#'   * `sector_ald` - the sector of the `ald` company
#'   * `name` - the name of the `loanbook` company
#'   * `name_ald` - the name of the `ald` company
#'   * `score` - the score of the match (manually set this to `1`
#'   prior to calling `prioritize()` to validate the match)
#'   * `source` - determines the source of the match. (equal to `loanbook`
#'   unless the match is from `overwrite`
#'
#'   The returned rows depend on the argument `min_value` and the result of the
#'   column `score` for each loan: * If any row has `score` equal to 1,
#'   `match_name()` returns all rows where `score` equals 1, dropping all other
#'   rows. * If no row has `score` equal to 1,`match_name()` returns all rows
#'   where `score` is equal to or greater than `min_score`. * If there is no
#'   match the output is a 0-row tibble with the expected column names -- for
#'   type stability.
#'
#' @export
#'
#' @examples
#' library(dplyr, warn.conflicts = FALSE)
#' library(r2dii.data)
#'
#' mini_loanbook <- sample_n(loanbook_demo, 10)
#' ald <- distinct(ald_demo, name_company, sector)
#'
#' match_name(mini_loanbook, ald)
#'
#' match_name(
#'   mini_loanbook, ald,
#'   min_score = 0.9,
#'   by_sector = TRUE
#' )
match_name <- function(loanbook,
                       ald,
                       by_sector = TRUE,
                       min_score = 0.8,
                       method = "jw",
                       p = 0.1,
                       overwrite = NULL) {
  old_groups <- dplyr::groups(loanbook)
  loanbook <- ungroup(loanbook)
  loanbook_rowid <- tibble::rowid_to_column(loanbook)

  prep_lbk <- restructure_loanbook(loanbook_rowid, overwrite = overwrite)
  prep_ald <- restructure_ald_for_matching(ald)

  if (by_sector) {
    a <- expand_alias(prep_lbk, prep_ald)
  } else {
    a <- tidyr::crossing(alias_lbk = prep_lbk$alias, alias_ald = prep_ald$alias)
  }

  setDT(a)

  if (identical(nrow(a), 0L)) {
    rlang::warn("Found no match.")
    return(empty_loanbook_tibble(loanbook, old_groups))
  }

  a <- unique(a)[
    ,
    score := stringdist::stringsim(
      alias_lbk, alias_ald,
      method = method, p = p
    )
  ]
  setkey(a, score)
  a <- a[score >= min_score, ]

  if (identical(nrow(a), 0L)) {
    rlang::warn("Found no match.")
    return(empty_loanbook_tibble(loanbook, old_groups))
  }

  l <- rename(prep_lbk, alias_lbk = .data$alias)
  setDT(l)
  matched <- a[l, on = "alias_lbk", nomatch = 0]
  matched <- matched[,
    pick := none_is_one(score) | some_is_one(score),
    by = id_2dii
  ][pick == TRUE][, pick := NULL]

  prep_ald <- rlang::set_names(prep_ald, paste0, "_ald")
  setDT(prep_ald)
  matched <- prep_ald[matched, on = "alias_ald", allow.cartesian = TRUE]

  if (by_sector) {
    matched <- matched[sector == sector_ald, ]
  }

  # Restore columns from loanbook
  setDT(loanbook_rowid)
  matched <- loanbook_rowid[matched, on = "rowid"]
  matched <- matched[, rowid := NULL]
  matched <- as_tibble(matched)

  matched <- reorder_names_as_in_loanbook(matched, loanbook_rowid)
  matched <- unsuffix_and_regroup(matched, old_groups)
  matched <- select(matched, -.data$alias, -.data$alias_ald)
  # Remove attribute added by data.table
  attr(matched, ".internal.selfref") <- NULL

  matched
}

empty_loanbook_tibble <- function(loanbook, old_groups) {
  types <- loanbook %>%
    purrr::map_chr(typeof)

  out <- named_tibble(names = minimum_names_of_match_name(loanbook)) %>%
    unsuffix_and_regroup(old_groups) %>%
    select(-.data$alias, -.data$alias_ald)

  tmp <- tempfile()
  utils::write.csv(out, tmp, row.names = FALSE)
  utils::read.csv(tmp, stringsAsFactors = FALSE, colClasses = types) %>%
    as_tibble()
}

# readr -------------------------------------------------------------------

expand_alias <- function(loanbook, ald) {
  vars <- c("sector", "alias")
  l <- dplyr::nest_by(select(loanbook, vars), .data$sector, .key = "alias_lbk")
  a <- dplyr::nest_by(select(ald, vars), .data$sector, .key = "alias_ald")
  la <- dplyr::inner_join(l, a, by = "sector")

  purrr::map2_df(
    la$alias_lbk, la$alias_ald,
    ~ tidyr::expand_grid(alias_lbk = .x$alias, alias_ald = .y$alias)
  )
}

unsuffix_and_regroup <- function(data, old_groups) {
  data %>%
    rename(alias = .data$alias_lbk) %>%
    group_by(!!!old_groups)
}

named_tibble <- function(names) {
  slice(as_tibble(set_names(as.list(names))), 0L)
}

minimum_names_of_match_name <- function(loanbook) {
  unique(c(names(loanbook), names_added_by_match_name()))
}

none_is_one <- function(x) {
  all(x != 1L)
}

some_is_one <- function(x) {
  any(x == 1L) & x == 1L
}

reorder_names_as_in_loanbook <- function(data, loanbook) {
  names_in_loanbook <- data %>%
    intersect_names_as_in(reference = loanbook)

  data %>%
    select(
      names_in_loanbook,
      # New names
      !!!names_added_by_match_name(),
      # In case I missed something
      dplyr::everything()
    )
}

# What names of `data` exist in `reference`? (order from reference)
intersect_names_as_in <- function(data, reference) {
  missing_names <- setdiff(names(reference), names(data))
  setdiff(names(reference), missing_names)
}

names_added_by_match_name <- function() {
  c(
    "id_2dii",
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
}
