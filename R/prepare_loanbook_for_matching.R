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
#'   prepare_loanbook_for_matching()
prepare_loanbook_for_matching <- function(data) {
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

#' Overwrite the name and/ or sector of prepared loanbook data
#'
#' This function overwrites the name and/ or sector of entities of the prepared
#' loanbook as specified by manual input. Entities to be overwritten are
#' identified by level (e.g. `direct_loantaker` or `ultimate_parent`) and ID.
#'
#' @param data A dataframe structured like the output of
#'   [prepare_loanbook_for_matching()].
#' @param overwrite A dataframe used to overwrite the sector and/or name of a
#'   particular direct loantaker or ultimate parent. If only name (sector)
#'   should be overwritten leave sector (name) as `NA`.
#'
#' @seealso [r2dii.dataraw::loanbook_description].
#' @family functions to prepare data for matching.
#'
#' @return A dataframe of all unique name + sector combinations, including all
#'   IDs, and with elements already manually overwritten.
#' @export
#'
#' @seealso [r2dii.dataraw::overwrite_demo] demo overwrite input file.
#'
#' @examples
#' library(r2dii.dataraw)
#'
#' loanbook_demo %>%
#'   bridge_sector() %>%
#'   prepare_loanbook_for_matching() %>%
#'   overwrite_name_sector(overwrite_demo)
overwrite_name_sector <- function(data, overwrite) {
  check_crucial_names(data, get_matching_columns())
  check_crucial_columns_of_overwrite(overwrite)

  data %>%
    dplyr::left_join(overwrite, by = c("id", "level")) %>%
    mutate(
      source = if_else(is.na(.data$source.y), .data$source.x, "manual"),
      sector = if_else(is.na(.data$sector.y), .data$sector.x, .data$sector.y),
      name = if_else(is.na(.data$name.y), .data$name.x, .data$name.y)
    ) %>%
    select(names(data))
}

#' Wrapper to simplify the name column of the prepared loanbook
#'
#' This function is a wrapper for `replace_customer_name` to simplify the name
#' column of the matching-prepared loanbook or ald file.
#'
#' @param data A dataframe structured like the output of
#'   [prepare_loanbook_for_matching()] or like an ald file.
#' @family functions to prepare data for matching.
#' @seealso [replace_customer_name] name simplification function.
#'
#' @return A matching-prepared file with simplified name.
#' @export
#'
#'
#' @examples
#' library(r2dii.dataraw)
#'
#' loanbook_demo %>%
#'   bridge_sector() %>%
#'   prepare_loanbook_for_matching() %>%
#'   simplify_name_column()
#'
#' loanbook_demo %>%
#'   bridge_sector() %>%
#'   prepare_loanbook_for_matching() %>%
#'   overwrite_name_sector(overwrite_demo) %>%
#'   simplify_name_column()
simplify_name_column <- function(data) {
  check_crucial_names(data, get_matching_columns())

  data %>%
    mutate(simplified_name = replace_customer_name(.data$name)) %>%
    select(
      .data$level,
      .data$id,
      .data$name,
      .data$sector,
      .data$source,
      .data$simplified_name
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

get_matching_columns <- function() {
  c(
    "level",
    "id",
    "name",
    "sector",
    "source"
  )
}

check_crucial_columns_of_overwrite <- function(overwrite) {
  check_crucial_names(overwrite, get_matching_columns())

  invisible(overwrite)
}
