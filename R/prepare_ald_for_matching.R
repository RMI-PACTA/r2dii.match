#' Prepare the ald elements to be matched.
#'
#' This function takes all unique name + sector combinations of the ald,
#' preparing it for the fuzzy matching process.
#'
#' @param data The ald dataframe.
#'
#' @return A dataframe of all unique name + sector combinations, including all
#'   IDs, and with elements already manually overwritten.
#' @export
#'
#' @examples
#' library(r2dii.dataraw)
#'
#' ald_demo %>%
#'   prepare_ald_for_matching()
#'
prepare_ald_for_matching <- function(data) {
  check_crucial_columns(data)

  data %>%
    extract_unique_name_and_sector()
}

check_crucial_columns <- function(data) {
  crucial_data <- c(
    "name_company",
    "sector"
  )
  check_crucial_names(data, crucial_data)

  invisible(data)
}

extract_unique_name_and_sector <- function(data) {
  data %>%
    select(
      .data$name_company,
      .data$sector
    ) %>%
    dplyr::distinct()
}
