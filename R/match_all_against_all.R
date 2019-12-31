#' Score similarity between `alias` values in two dataframes
#'
#' Apply `score_similarity()` to all combinations of `alias` values
#' from two dataframes.
#'
#' @param loanbook,ald Dataframes with `alias` and optionally `sector`
#'   columns.
#' @param ... Additional arguments are passed on to [stringdist::stringsim].
#' @param by_sector Should the combinations be done by sector?
#' @inheritParams stringdist::stringdist
#'
#' @family internal-ish
#'
#' @return A [dplyr::tibble].
#' @export
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
#' out <- match_all_against_all(loanbook, ald)
#'
#' # Recover sector
#' left_join(out, loanbook, by = c("alias_lbk" = "alias"))
#'
#' threshold <- 0.5
#' match_all_against_all(loanbook, ald) %>%
#'   filter(score >= threshold)
#'
#' out <- match_all_against_all(loanbook, ald, by_sector = FALSE)
#' out
#'
#' # Recover sectors from x & y
#' left_join(out, loanbook, by = c("alias_lbk" = "alias")) %>%
#'   rename(sector_x = sector) %>%
#'   left_join(ald, by = c("alias_ald" = "alias")) %>%
#'   rename(sector_y = sector)
match_all_against_all <- function(loanbook,
                                  ald,
                                  ...,
                                  by_sector = TRUE,
                                  method = "jw",
                                  p = 0.1) {
  ellipsis::check_dots_used()

  if (by_sector) {
    out <- expand_alias_by_sector(loanbook, ald)
  } else {
    out <- cross_alias(loanbook, ald)
  }

  unique(
    mutate(
      out,
      score = score_similarity(
        out$alias_lbk, out$alias_ald, ...,
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
