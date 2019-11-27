#' Score similarity between `simpler_name` values in two dataframes, by sector
#'
#' Apply `string_similarity()` to all combinations of `simpler_name` values
#' from two dataframes.
#'
#' @param x,y Dataframes with `simpler_name` and optionally `sector` columns.
#' @param group_by_sector Should the combinations be done by sector?
#'
#' @return A [tibble::tibble].
#' @export
#'
#' @examples
#' library(dplyr)
#'
#' x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
#' y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))
#'
#' scores <- match_all_against_all(x, y)
#' scores %>%
#'   dplyr::filter(score > 0.5)
#'
#' match_all_against_all(x, y, group_by_sector = FALSE)
match_all_against_all <- function(x, y, group_by_sector = TRUE) {
  if (group_by_sector) {
    out <- expand_simpler_name_by_sector(x, y)
  } else {
    out <- cross_simpler_name(x, y)
  }

  mutate(
    out,
    score = string_similarity(out$simpler_name_x, out$simpler_name_y)
  )
}

expand_simpler_name_by_sector <- function(x, y) {
  vars <- c("sector", "simpler_name")

  check_crucial_names(x, vars)
  check_crucial_names(y, vars)

  dplyr::left_join(
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
