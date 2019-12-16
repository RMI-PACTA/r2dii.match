#' Match two datasets, commonly a loanbook and ald, by the `simpler_name` column
#'
#' @inherit match_all_against_all
#'
#' @param threshold A length-1 numeric vector giving a `score` to filter the
#'   result, so that it only contains values above `threshold`.
#'
#' @export
#'
#' @examples
#' x <- tibble(sector = c("A", "B", "B"), simpler_name = c("xa", "xb", "xc"))
#' y <- tibble(sector = c("A", "B", "C"), simpler_name = c("ya", "yb", "yc"))
#'
#' match_by_simpler_name(x, y, treshold = 0)
match_by_simpler_name <- function(x,
                                  y,
                                  ...,
                                  by_sector = TRUE,
                                  threshold = 0.8,
                                  method = "jw",
                                  p = 0.1) {
  matched <- match_all_against_all(x, y, by_sector = FALSE)

  with_sector_x <- matched %>%
    left_join(x, by = c("simpler_name_x" = "simpler_name")) %>%
    dplyr::rename(sector_x = sector)
  with_sector_xy <- with_sector_x %>%
    left_join(y, by = c("simpler_name_y" = "simpler_name")) %>%
    dplyr::rename(sector_y = sector)
  out <- dplyr::filter(with_sector_xy, score >= threshold)

  out
}
