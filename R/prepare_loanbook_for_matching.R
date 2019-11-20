#' A convenient shortcut to prepare loanbook data for matching
#'
#' This function is a convenient shortcut for the most common steps for
#' preparing a loanbook dataset for matching.
#'
#' @family functions to prepare data for matching.
#' @seealso [r2dii.dataraw::loanbook_description].
#' @inheritParams pull_unique_name_sector_combinations
#' @inheritParams overwrite_name_sector
#'
#' @export
#' @return A dataframe prepared for matching.
#'
#' @examples
#' library(r2dii.dataraw)
#'
#' prepare_loanbook_for_matching(loanbook_demo)
#'
#' loanbook_demo %>%
#'   prepare_loanbook_for_matching(overwrite = overwrite_demo)
prepare_loanbook_for_matching <- function(data, overwrite = NULL) {
  out <- pull_unique_name_sector_combinations(bridge_sector(data))
  if (!is.null(overwrite)) {
    out <- overwrite_name_sector(out, overwrite = overwrite)
  }

  mutate(out, simpler_name = replace_customer_name(.data$name))
}
