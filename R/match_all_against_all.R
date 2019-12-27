#' Score similarity between `simpler_name` values in two dataframes
#'
#' Apply `string_similarity()` to all combinations of `simpler_name` values
#' from two dataframes.
#'
#' @param loanbook,ald Dataframes with `simpler_name` and optionally `sector`
#'   columns.
#' @param ... Additional arguments are passed on to [stringdist::stringsim].
#' @param by_sector Should the combinations be done by sector?
#' @inheritParams stringdist::stringdist
#'
#' @family user-oriented
#'
#' @return A [dplyr::tibble].
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' loanbook <- tibble(
#'   sector = c("A", "B", "B"),
#'   simpler_name = c("xa", "xb", "xc")
#' )
#'
#' ald <- tibble(
#'   sector = c("A", "B", "C"),
#'   simpler_name = c("ya", "yb", "yc")
#' )
#'
#' out <- match_all_against_all(loanbook, ald)
#'
#' # Recover sector
#' left_join(out, loanbook, by = c("simpler_name_x" = "simpler_name"))
#'
#' threshold <- 0.5
#' match_all_against_all(loanbook, ald) %>%
#'   filter(score >= threshold)
#'
#' out <- match_all_against_all(loanbook, ald, by_sector = FALSE)
#' out
#'
#' # Recover sectors from x & y
#' left_join(out, loanbook, by = c("simpler_name_x" = "simpler_name")) %>%
#'   rename(sector_x = sector) %>%
#'   left_join(ald, by = c("simpler_name_y" = "simpler_name")) %>%
#'   rename(sector_y = sector)
match_all_against_all <- function(loanbook,
                                  ald,
                                  ...,
                                  by_sector = TRUE,
                                  method = "jw",
                                  p = 0.1) {
  ellipsis::check_dots_used()

  if (by_sector) {
    out <- expand_simpler_name_by_sector(loanbook, ald)
  } else {
    out <- cross_simpler_name(loanbook, ald)
  }

  unique(
    mutate(
      out,
      score = string_similarity(
        out$simpler_name_x, out$simpler_name_y, ...,
        method = method, p = p
      )
    )
  )
}

expand_simpler_name_by_sector <- function(x, y) {
  vars <- c("sector", "simpler_name")

  check_crucial_names(x, vars)
  check_crucial_names(y, vars)

  dplyr::inner_join(
    select(x, vars), select(y, vars),
    by = "sector", suffix = c("_x", "_y")
  ) %>%
    dplyr::group_by(.data$sector) %>%
    tidyr::expand(.data$simpler_name_x, .data$simpler_name_y) %>%
    dplyr::ungroup() %>%
    select(-.data$sector)
}

cross_simpler_name <- function(x, y) {
  check_crucial_names(x, "simpler_name")
  check_crucial_names(y, "simpler_name")

  tidyr::crossing(
    simpler_name_x = x$simpler_name,
    simpler_name_y = y$simpler_name
  )
}
