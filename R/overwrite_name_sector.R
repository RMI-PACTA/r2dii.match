#' Overwrite the name and/ or sector of prepared loanbook data
#'
#' This function overwrites the name and/ or sector of entities of the prepared
#' loanbook as specified by manual input. Entities to be overwritten are
#' identified by level (e.g. `direct_loantaker` or `ultimate_parent`) and ID.
#'
#' @param data A dataframe structured like the output of
#'   [pull_unique_name_sector_combinations()].
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
#'   pull_unique_name_sector_combinations() %>%
#'   overwrite_name_sector(overwrite_demo)
overwrite_name_sector <- function(data, overwrite) {
  check_crucial_names(data, get_matching_columns())
  check_crucial_names(overwrite, get_matching_columns())

  data %>%
    dplyr::left_join(overwrite, by = c("id", "level")) %>%
    mutate(
      source = if_else(is.na(.data$source.y), .data$source.x, "manual"),
      sector = if_else(is.na(.data$sector.y), .data$sector.x, .data$sector.y),
      name = if_else(is.na(.data$name.y), .data$name.x, .data$name.y)
    ) %>%
    select(names(data))
}
