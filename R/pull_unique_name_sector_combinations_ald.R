#' Prepare the ald elements to be matched.
#'
#' This function takes all unique name + sector combinations of the ald,
#' preparing it for the fuzzy matching process.
#'
#' @param data A dataframe structured like [r2dii.dataraw::ald_demo].
#'
#' @family functions to prepare data for matching.
#' @seealso [r2dii.dataraw::ald_description].
#'
#' @return A dataframe of all unique name + sector combinations.
#' @export
#'
#' @examples
#' library(r2dii.dataraw)
#'
#' ald_demo %>%
#'   pull_unique_name_sector_combinations_ald()

pull_unique_name_sector_combinations_ald <- function(data){
  check_crucial_columns_of_ald_data(data)

  data %>%
    dplyr::rename(
      name = .data$name_company
    ) %>%
    dplyr::select(
      .data$name,
      .data$sector
    ) %>%
    dplyr::distinct()
}

check_crucial_columns_of_ald_data <- function(data) {
  crucial_data <- c(
    "name_company",
    "sector"
  )
  check_crucial_names(data, crucial_data)

  invisible(data)
}
