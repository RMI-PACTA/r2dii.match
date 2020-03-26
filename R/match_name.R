#' Match a loanbook and asset-level datasets (ald) by the `name_*` columns
#'
#' `match_name()` scores the match between names in a loanbook dataset (columns
#' can be `name_direct_loantaker`, `name_intermediate_parent_*`and
#' `name_ultimate_parent`) with names in an asset-level dataset (column
#' `name_company`). The raw names are first internally transformed, and aliases
#' are assigned. The similarity between aliases in each of the loanbook and ald
#' datasets is scored using [stringdist::stringsim()].
#'
#'
#' @template alias-assign
#' @template ignores-but-preserves-existing-groups
#'
#' @param loanbook,ald Dataframes structured like [r2dii.data::loanbook_demo]
#'   and [r2dii.data::ald_demo].
#' @param by_sector Should names only be compared if companies belong to the same
#'   `sector`?
#' @param min_score A number between 0-1, to set the minimum `score` threshold.
#'   A `score` of 1 is a perfect match.
#' @param method Method for distance calculation. One of `c("osa", "lv", "dl",
#'   "hamming", "lcs", "qgram", "cosine", "jaccard", "jw", "soundex")`. See
#'   [stringdist::stringdist-metrics].
#' @inheritParams stringdist::stringdist
#' @param overwrite A dataframe used to overwrite the `sector` and/or `name`
#'   columns of a particular direct loantaker or ultimate parent. To overwrite
#'   only `sector`, the value in the `name` column should be `NA` and
#'   vice-versa. This file can be used to manually match loanbook companies to ald.
#'
#' @family user-oriented
#'
#' @return A dataframe with the same groups (if any) and columns as `loanbook`,
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
#' library(r2dii.data)
#' library(dplyr)
#'
#' mini_loanbook <- sample_n(loanbook_demo, 10)
#'
#' match_name(mini_loanbook, ald_demo)
#'
#' match_name(
#'   mini_loanbook, ald_demo,
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

  prep_lbk <- suppressMessages(
    restructure_loanbook_for_matching(loanbook_rowid, overwrite = overwrite)
  )
  prep_ald <- restructure_ald_for_matching(ald)

  matched <- score_alias_similarity(
    prep_lbk, prep_ald,
    by_sector = by_sector,
    method = method,
    p = p
  ) %>%
    pick_min_score(min_score)

  no_match <- identical(nrow(matched), 0L)
  if (no_match) {
    rlang::warn("Found no match.")
    out <- named_tibble(names = minimum_names_of_match_name(loanbook)) %>%
      unsuffix_and_regroup(old_groups) %>%
      select(-.data$alias, -.data$alias_ald)
    return(out)
  }

  preferred <- prefer_perfect_match_by(matched, .data$id_2dii)

  preferred %>%
    restore_cols_sector_name_from_ald(prep_ald, by_sector = by_sector) %>%
    # Restore columns from loanbook
    left_join(loanbook_rowid, by = "rowid") %>%
    mutate(rowid = NULL) %>%
    reorder_names_as_in_loanbook(loanbook_rowid) %>%
    unsuffix_and_regroup(old_groups) %>%
    select(-.data$alias, -.data$alias_ald)
}

unsuffix_and_regroup <- function(data, old_groups) {
  data %>%
    rename(alias = .data$alias_lbk) %>%
    dplyr::group_by(!!!old_groups)
}

pick_min_score <- function(data, min_score) {
  data %>%
    filter(.data$score >= min_score) %>%
    unique()
}

named_tibble <- function(names) {
  dplyr::slice(tibble::as_tibble(set_names(as.list(names))), 0L)
}

minimum_names_of_match_name <- function(loanbook) {
  unique(c(names(loanbook), names_added_by_match_name()))
}

restore_cols_sector_name_from_ald <- function(matched, prep_ald, by_sector) {
  out <- matched %>%
    left_join(rlang::set_names(prep_ald, paste0, "_ald"), by = "alias_ald")

  if (!by_sector) {
    return(out)
  }

  out %>% filter(.data$sector == .data$sector_ald)
}

prefer_perfect_match_by <- function(data, ...) {
  data %>%
    group_by(...) %>%
    filter(none_is_one(.data$score) | some_is_one(.data$score)) %>%
    ungroup()
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
