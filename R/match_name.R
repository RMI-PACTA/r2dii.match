#' Match a loanbook and asset-level datasets by the `name_*` columns
#'
#' `match_name()` scores the match between names in a loanbook dataset (columns
#' `name_direct_loantaker` and `name_ultimate_parent`) with names in an
#' asset-level dataset (colum n `name_company`). The raw names are first
#' transformed and stored in a `simple_name` column, then the similarity between
#' the `simple_name` columns in each of the loanbook and ald datasets is scored
#' using [stringdist::stringsim()].
#'
#' The process to create the `simple_name` columns applies best practices
#' commonly used in name matching algorithms, such as:
#' * Remove special characters.
#' * Replace language specific characters.
#' * Abbreviate certain names to reduce their importance in the matching.
#' * Spell out numbers to increase their importance.
#'
#' @inherit match_all_against_all
#' @inheritParams prepare_loanbook_for_matching
#' @param min_score A number (length-1) to set the minimum `score` values you
#'   want to pick.
#'
#' @return A dataframe with the same columns as the loanbook data with
#'   additional columns: `id`, `sector_x`, `source`, `simpler_name_x`,
#'   `simpler_name_y`, `score`, `name_y`, `sector_y`.
#'
#' @export
#'
#' @examples
#' # Use tibble()
#' library(dplyr)
#' library(r2dii.dataraw)
#'
#' match_name(loanbook_demo, ald_demo)
#'
#' match_name(
#'   loanbook_demo, ald_demo,
#'   min_score = 0.5,
#'   by_sector = FALSE
#' )
match_name <- function(loanbook,
                       ald,
                       by_sector = TRUE,
                       min_score = 0.8,
                       method = "jw",
                       p = 0.1,
                       overwrite = NULL) {
  prep_lbk <- suppressMessages(
    prepare_loanbook_for_matching(loanbook, overwrite = overwrite)
  )
  prep_ald <- prepare_ald_for_matching(ald)

  matched <- match_all_against_all(
    prep_lbk, prep_ald,
    by_sector = by_sector,
    method = method,
    p = p
  )

  matched %>%
    pick_min_score(min_score = min_score) %>%
    restore_sector_name_and_other_columns(
      prep_lbk = prep_lbk,
      prep_ald = prep_ald
    ) %>%
    restore_loanbook_columns(loanbook)
}

suffix_names <- function(data, names, suffix) {
  nms_suffix <- set_names(names, paste0, suffix)
  rename(data, !!nms_suffix)
}

restore_sector_name_and_other_columns <- function(matched, prep_lbk, prep_ald) {
  nms <- c("simpler_name", "sector", "name")
  prep_lbk_x <- suffix_names(prep_lbk, nms, "_x")
  prep_ald_y <- suffix_names(prep_ald, nms, "_y")

  matched %>%
    left_join(prep_lbk_x, by = "simpler_name_x") %>%
    left_join(prep_ald_y, by = "simpler_name_y")
}

pick_min_score <- function(data, min_score) {
  data %>%
    filter(.data$score >= min_score) %>%
    unique()
}

restore_loanbook_columns <- function(matched, loanbook) {
  with_name_prefix <- matched %>%
    tidyr::pivot_wider(
      names_from = "level",
      values_from = "name_x",
      names_prefix = "name_"
    )

  left_join(
    with_name_prefix, loanbook,
    by = c("name_ultimate_parent", "name_direct_loantaker")
  )
}
