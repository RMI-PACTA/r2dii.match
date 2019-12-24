#' Match two datasets, commonly a loanbook and ald, by the `simpler_name` column
#'
#' @inherit match_all_against_all
#'
#' @inheritParams prepare_loanbook_for_matching
#' @param min_score A number (length-1) to set the minimum `score` values you
#'   want to pick.
#'
#' @export
#'
#' @examples
#' # Use tibble()
#' library(dplyr)
#' library(r2dii.dataraw)
#'
#' match_name(loanbook_demo, ald_demo, min_score = 0)
#'
#' match_name(loanbook_demo, ald_demo, min_score = 0.5, by_sector = FALSE)
#'
#' match_name(loanbook_demo, ald_demo, min_score = 0.5, by_sector = TRUE)
match_name <- function(x,
                       y,
                       ...,
                       by_sector = TRUE,
                       min_score = 0.8,
                       method = "jw",
                       p = 0.1,
                       overwrite = NULL) {
  prep_lbk <- prepare_loanbook_for_matching(data = x, overwrite = overwrite)
  prep_ald <- prepare_ald_for_matching(data = y)

  nms  <- c("simpler_name", "sector", "name")

  loanbook_x <- suffix_names(prep_lbk, nms, "_x")
  matched <- match_all_against_all(
    x = prep_lbk,
    y = prep_ald,
    ...,
    by_sector = by_sector,
    method = method,
    p = p
  )
  with_sector_x <- left_join(loanbook_x, matched, by = "simpler_name_x")

  ald_y <- suffix_names(prep_ald, nms, "_y")
  with_sector_xy <- left_join(with_sector_x, ald_y, by = "simpler_name_y")

  filter(with_sector_xy, .data$score >= min_score)
}

suffix_names <- function(data, names, suffix) {
  nms_suffix <- set_names(names, paste0, suffix)
  rename(data, !! nms_suffix)
}
