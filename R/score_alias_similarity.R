#' Score similarity between `alias` values in two dataframes
#'
#' Apply `score_string_similarity()` to all combinations of `alias` values
#' from two dataframes.
#'
#' @inheritParams match_name
#'
#' @seealso [match_name].
#'
#' @return A [tibble::tibble].
#'
#' @examples
#' library(dplyr)
#'
#' loanbook <- tibble(
#'   sector = c("A", "B", "B"),
#'   alias = c("xa", "xb", "xc")
#' )
#'
#' ald <- tibble(
#'   sector = c("A", "B", "C"),
#'   alias = c("ya", "yb", "yc")
#' )
#'
#' score_alias_similarity(loanbook, ald)
#'
#' score_alias_similarity(loanbook, ald, by_sector = FALSE)
#' @noRd
score_alias_similarity <- function(loanbook,
                                   ald,
                                   by_sector = TRUE,
                                   method = "jw",
                                   p = 0.1) {
  if (by_sector) {
    out <- expand_alias_by_sector(loanbook, ald)
  } else {
    out <- cross_alias(loanbook, ald)
  }

  out <- left_join(out, loanbook, by = c("alias_lbk" = "alias"))

  unique(
    mutate(
      out,
      score = score_string_similarity(
        out$alias_lbk, out$alias_ald,
        method = method, p = p
      )
    )
  )
}

expand_alias_by_sector <- function(loanbook, ald) {
  vars <- c("sector", "alias")

  check_crucial_names(loanbook, vars)
  check_crucial_names(ald, vars)

  dplyr::inner_join(
    select(loanbook, vars), select(ald, vars),
    by = "sector", suffix = c("_lbk", "_ald")
  ) %>%
    dplyr::group_by(.data$sector) %>%
    tidyr::expand(.data$alias_lbk, .data$alias_ald) %>%
    dplyr::ungroup() %>%
    select(-.data$sector)
}

cross_alias <- function(loanbook, ald) {
  check_crucial_names(loanbook, "alias")
  check_crucial_names(ald, "alias")

  tidyr::crossing(
    alias_lbk = loanbook$alias,
    alias_ald = ald$alias
  )
}
