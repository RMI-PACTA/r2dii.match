#' Match a loanbook and asset-level datasets (ald) by the `name_*` columns
#'
#' `match_name()` scores the match between names in a loanbook dataset (columns
#' `name_direct_loantaker` and `name_ultimate_parent`) with names in an
#' asset-level dataset (column `name_company`). The raw names are first
#' transformed and stored in an `alias` column, then the similarity between
#' the `alias` columns in each of the loanbook and ald datasets is scored
#' using [stringdist::stringsim()].
#'
#' @template alias-assign
#' @template ignores-but-preserves-existing-groups
#'
#' @inherit score_alias_similarity
#' @inheritParams restructure_loanbook_for_matching
#' @param min_score A number (length-1) to set the minimum `score` values you
#'   want to pick.
#'
#' @family user-oriented
#'
#' @return A dataframe with the same groups (if any) and columns as `loanbook`,
#'   and the additional columns: `id`, `sector`, `sector_ald`, `source`,
#'   `alias`, `alias_ald`, `score`, `name_ald`. The returned rows depend on the
#'   argument `min_value` and the result of the column `score` for each loan:
#'   * If any row has `score` equal to 1, `match_name()` returns all rows where
#'   `score` equals 1, dropping all other rows.
#'   * If no row has `score` equal to 1, `match_name()` returns all rows where
#'   `score` is equal to or greater than `min_score`.
#'
#' If there is no match the output is a 0-row tibble with the expected column
#' names -- for type stability.
#'
#' @export
#'
#' @examples
#' library(dplyr)
#' library(r2dii.dataraw)
#'
#' match_name(loanbook_demo, ald_demo)
#'
#' match_name(
#'   loanbook_demo, ald_demo,
#'   min_score = 0.9,
#'   by_sector = FALSE
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

  prep_lbk <- suppressMessages(
    restructure_loanbook_for_matching(loanbook, overwrite = overwrite)
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
    warning("Found no match.", call. = FALSE)
    return(named_tibble(names = minimum_names_of_match_name(loanbook)))
  }

  out <- matched %>%
    restore_cols_sector_name_and_others(prep_lbk, prep_ald) %>%
    restore_cols_from_loanbook(loanbook) %>%
    prefer_perfect_match_by(.data$id_lbk) %>%
    tidy_match_name_result() %>%
    reorder_names_as_in_loanbook(loanbook)

  dplyr::group_by(out, !!!old_groups)
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
  pattern <- collapse_pipe(glue("^name_{level_root()}"))
  name_starts_with_name_level <- grep(pattern, names(loanbook), value = TRUE)

  unique(c(
    setdiff(names(loanbook), name_starts_with_name_level),
    names_added_by_match_name()
  ))
}

level_root <- function() {
  c("direct", "intermediate", "ultimate")
}

collapse_pipe <- function(x) {
  paste0(x, collapse = "|")
}

restore_cols_sector_name_and_others <- function(matched, prep_lbk, prep_ald) {
  matched %>%
    left_join(suffix_names(prep_lbk, "_lbk"), by = "alias_lbk") %>%
    left_join(suffix_names(prep_ald, "_ald"), by = "alias_ald")
}

restore_cols_from_loanbook <- function(matched, loanbook) {
  with_level_cols <- matched %>%
    tidyr::pivot_wider(
      names_from = "level_lbk",
      values_from = "name_lbk",
      names_prefix = "name_"
    )

  level_cols <- paste0("name_", unique(matched$level_lbk))

  left_join(
    suffix_names(with_level_cols, "_lbk", level_cols),
    suffix_names(loanbook, "_lbk"),
    by = paste0(level_cols, "_lbk")
  )
}

suffix_names <- function(data, suffix, names = NULL) {
  if (is.null(names)) {
    return(suffix_all_names(data, suffix))
  } else {
    suffix_some_names(data, suffix, names)
  }
}

suffix_all_names <- function(data, suffix) {
  set_names(data, paste0, suffix)
}

suffix_some_names <- function(data, suffix, names) {
  newnames_oldnames <- set_names(names, paste0, suffix)
  rename(data, !!!newnames_oldnames)
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

tidy_match_name_result <- function(data) {
  level_cols <- data %>%
    names_matching(level = get_level_columns())

  data %>%
    tidyr::pivot_longer(
      cols = level_cols,
      names_to = "level_lbk",
      values_to = "name_lbk"
    ) %>%
    mutate(
      level_lbk = sub("^name_", "", .data$level_lbk),
      level_lbk = sub("_lbk$", "", .data$level_lbk),
    ) %>%
    remove_suffix("_lbk")
}

names_matching <- function(x, level) {
  pattern <- paste0(glue("^name_{level}.*_lbk$"), collapse = "|")
  grep(pattern, names(x), value = TRUE)
}

get_level_columns <- function() {
  c("direct_", "intermediate_", "ultimate_")
}

remove_suffix <- function(data, suffix) {
  set_names(data, ~ sub(suffix, "", .x))
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
    "id",
    "level",
    "sector",
    "sector_ald",
    "name",
    "name_ald",
    "alias",
    "alias_ald",
    "score",
    "source"
  )
}

crucial_loanbook_names_for_match_name <- function() {
  c(
    "id_ultimate_parent",
    "name_ultimate_parent",
    "id_direct_loantaker",
    "name_direct_loantaker",
    "sector_classification_system",
    "sector_classification_direct_loantaker"
  )
}
