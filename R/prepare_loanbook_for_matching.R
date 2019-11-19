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

  # join in manual values
  loanbook_match_values_overwrite <- dplyr::left_join(
    loanbook_match_values, overwrite, by = c("id", "level")
  ) %>%
    mutate(
      name = .data$name.y %|% .data$name.x,
      sector = .data$sector.y %|% .data$sector.x
    ) %>%
    mutate(source = if_else(is.na(.data$source.y), .data$source.x, "manual")) %>%
    select(.data$level, .data$id, .data$name, .data$sector, .data$source)

  # simplify name
  loanbook_match_values_overwrite %>%
    mutate(
      simplified_name = r2dii.match::replace_customer_name(.data$name)
    )
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
