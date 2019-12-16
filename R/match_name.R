#' Match two datasets, commonly a loanbook and ald, by the `simpler_name` column
#'
#' @inherit match_all_against_all
#'
#' @param min_score A number (length-1) to set the minimum `score` values you
#'   want to pick.
#'
#' @export
#'
#' @examples
#' # Use tibble()
#' library(dplyr)
#'
#' x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
#' y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))
#'
#' match_name(x, y, min_score = 0)
#'
#' match_name(x, y, min_score = 0.5, by_sector = FALSE)
#'
#' match_name(x, y, min_score = 0.5, by_sector = TRUE)
match_name <- function(x,
                                  y,
                                  ...,
                                  by_sector = TRUE,
                                  min_score = 0.8,
                                  method = "jw",
                                  p = 0.1) {
  matched <- match_all_against_all(
    x = x,
    y = y,
    ...,
    by_sector = by_sector,
    method = method,
    p = p
  )

  with_sector_x <- matched %>%
    left_join(x, by = c("simpler_name_x" = "simpler_name")) %>%
    dplyr::rename(sector_x = .data$sector)
  with_sector_xy <- with_sector_x %>%
    left_join(y, by = c("simpler_name_y" = "simpler_name")) %>%
    dplyr::rename(sector_y = .data$sector)
  out <- filter(with_sector_xy, .data$score >= min_score)

  out
}
