#' Prepare the loanbook elements to be matched.
#'
#' This function takes all unique name + sector combinations of a loanbook,
#' preparing it for the fuzzy matching process.
#'
#' @param data A sector bridged loanbook dataframe.
#' @param overwrite A dataframe used to overwrite the sector and/or name of a
#'   particular loan, direct loantaker or ultimate parent. Elements to be
#'   overwritten are identified by any one of their IDs (loan, direct loantaker
#'   or ultimate parent).
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
#'   prepare_loanbook_for_matching()
prepare_loanbook_for_matching <- function(data, overwrite = NULL) {
  check_crucial_columns_of_loanbook_data(data)

  overwrite <- overwrite %||% init_overwrite()
  # Must run after init_overwrite
  check_crucial_columns_of_overwrite(overwrite)

  # extract all unique id & name pairs, with corresponding level and sector
  loanbook_match_values <- data %>%
    dplyr::select(
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
    dplyr::mutate(
      name =
        ifelse(.data$level == "direct_loantaker", .data$name_direct_loantaker, NA)
    ) %>%
    dplyr::mutate(
      name =
        ifelse(.data$level == "ultimate_parent", .data$name_ultimate_parent, .data$name)
    ) %>%
    dplyr::mutate(source = "loanbook") %>%
    dplyr::select(.data$level, .data$id, .data$name, .data$sector, .data$source) %>%
    dplyr::distinct()

  # join in manual values
  loanbook_match_values_overwrite <- dplyr::left_join(loanbook_match_values, overwrite, by = c("id", "level")) %>%
    dplyr::mutate(
      name = ifelse(is.na(.data$name.y), .data$name.x, .data$name.y),
      sector = ifelse(is.na(.data$sector.y), .data$sector.x, .data$sector.y),
      source = ifelse(is.na(.data$source.y), .data$source.x, "manual")
    ) %>%
    dplyr::select(.data$level, .data$id, .data$name, .data$sector, .data$source)

  # simplify name
  loanbook_match_values_overwrite %>%
    dplyr::mutate(simplified_name = r2dii.match::replace_customer_name(.data$name))
}

check_crucial_columns_of_loanbook_data <- function(data) {
  crucial_data <- c(
    "name_direct_loantaker",
    "name_ultimate_parent",
    "id_direct_loantaker",
    "id_ultimate_parent",
    "sector"
  )
  r2dii.utils::check_crucial_names(data, crucial_data)
}

check_crucial_columns_of_overwrite <- function(overwrite) {
  crucial_overwrite <- c(
    "level",
    "id",
    "name",
    "sector",
    "source"
  )
  r2dii.utils::check_crucial_names(overwrite, crucial_overwrite)
}

init_overwrite <- function() {
  tibble(
    level = character(),
    id = character(),
    name = character(),
    sector = character(),
    source = character()
  )
}
