#' Score similarity between `simpler_name` values in two dataframes, by sector
#'
#' Apply `string_similarity()` to all combinations of `simpler_name` values, by
#' sector, from two dataframes.
#'
#' @param x,y Dataframes
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
#' scores <- score_simpler_name_by_sector(x, y)
#' scores
#'
#' scores %>%
#'   dplyr::filter(score > 0.5)
score_simpler_name_by_sector <- function(x, y) {
  vars <- c("sector", "simpler_name")

  check_crucial_names(x, vars)
  check_crucial_names(y, vars)

  joint <- dplyr::left_join(select(x, vars), select(y, vars), by = "sector")

  exapnded <- joint %>%
    dplyr::group_by(.data$sector) %>%
    tidyr::expand(.data$simpler_name.x, .data$simpler_name.y) %>%
    dplyr::ungroup()

  exapnded %>%
    mutate(
      score = string_similarity(.data$simpler_name.x, .data$simpler_name.y)
    )
}
