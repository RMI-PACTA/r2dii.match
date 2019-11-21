#' A convenient shortcut to prepare ald data for matching
#'
#' This function is a convenient shortcut for the most common steps for
#' preparing the ald dataset for matching.
#'
#' @family functions to prepare data for matching.
#' @seealso [r2dii.dataraw::ald_description].
#' @inheritParams pull_unique_name_sector_combinations_ald
#'
#' @export
#' @return A dataframe prepared for matching.
#'
#' @examples
#' library(r2dii.dataraw)
#'
#' prepare_ald_for_matching(ald_demo)

prepare_ald_for_matching <- function(data) {
  out <- pull_unique_name_sector_combinations_ald(data)

  mutate(out, simpler_name = replace_customer_name(.data$name))
}
