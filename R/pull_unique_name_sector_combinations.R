#' Prepare the loanbook elements to be matched.
#'
#' This function takes all unique name + sector combinations of a loanbook,
#' preparing it for the fuzzy matching process.
#'
#' @param data A dataframe structured like the output of [bridge_sector()].
#'
#' @family functions to prepare data for matching.
#' @seealso [r2dii.dataraw::loanbook_description].
#'
#' @return A dataframe of all unique name + sector combinations, including all
#'   IDs, and with elements already manually overwritten.
#' @export
#'
#' @examples
#' library(r2dii.dataraw)
#'
#' loanbook_demo %>%
#'   bridge_sector() %>%
#'   pull_unique_name_sector_combinations()
pull_unique_name_sector_combinations <- function(data) {
  check_crucial_columns_of_loanbook_data(data)

  data %>%
    select(
      .data$id_direct_loantaker,
      .data$name_direct_loantaker,
      .data$id_ultimate_parent,
      .data$name_ultimate_parent,
      .data$sector
    ) %>%
    tidyr::pivot_longer(
      cols = tidyr::starts_with("id_"),
      names_to = "level",
      names_prefix = "id_",
      values_to = "id"
    ) %>%
    mutate(
      name = if_else(
        .data$level == "direct_loantaker",
        .data$name_direct_loantaker,
        NA_character_
      ),
      name = if_else(
        .data$level == "ultimate_parent",
        .data$name_ultimate_parent,
        .data$name
      ),
      source = "loanbook"
    ) %>%
    select(
      .data$level,
      .data$id,
      .data$name,
      .data$sector,
      .data$source
    ) %>%
    dplyr::distinct()
}

check_crucial_columns_of_loanbook_data <- function(data) {
  crucial_data <- c(
    "name_direct_loantaker",
    "name_ultimate_parent",
    "id_direct_loantaker",
    "id_ultimate_parent",
    "sector"
  )
  check_crucial_names(data, crucial_data)

  invisible(data)
}
