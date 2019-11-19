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
  check_crucial_columns_of_overwrite(overwrite %||% init_overwrite())

  data %>%
    extract_unique_id_and_name_with_level_and_sector() %>%
    join_in_manual_values(overwrite %||% init_overwrite())
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

check_crucial_columns_of_overwrite <- function(overwrite) {
  crucial_overwrite <- c(
    "level",
    "id",
    "name",
    "sector",
    "source"
  )
  check_crucial_names(overwrite, crucial_overwrite)

  invisible(overwrite)
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

extract_unique_id_and_name_with_level_and_sector <- function(data) {
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

join_in_manual_values <- function(data, overwrite) {
  data %>%
    dplyr::left_join(overwrite, by = c("id", "level")) %>%
    mutate(
      source = if_else(is.na(.data$source.y), .data$source.x, "manual"),
      sector = if_else(is.na(.data$sector.y), .data$sector.x, .data$sector.y),
      name = if_else(is.na(.data$name.y), .data$name.x, .data$name.y),
      simplified_name = replace_customer_name(.data$name)
    ) %>%
    select(
      .data$level,
      .data$id,
      .data$name,
      .data$sector,
      .data$source,
      .data$simplified_name
    )
}
