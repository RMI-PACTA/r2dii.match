#' Prepare the loanbook elements to be matched.
#'
#' This function takes all unique name + sector combinations of a loanbook,
#' preparing it for the fuzzy matching process.
#'
#' @param data A sector bridged loanbook dataframe.
#' @param overwrite A dataframe used to overwrite the sector and/or name of a particular loan,
#' direct loantaker or ultimate parent. Elements to be overwritten are identified by any one of
#' their IDs (loan, direct loantaker or ultimate parent).
#'
#' @return A dataframe of all unique name + sector combinations, including all IDs, and with elements already manually overwritten.
#' @export
#'
#' @examples
#' library(r2dii.dataraw)
#'
#' input_loanbook <- r2dii.dataraw::loanbook_demo
#'
#' sector_bridged_loanbook <- r2dii.match::bridge_sector(input_loanbook)
#'
#' prepare_loanbook_for_matching(sector_bridged_loanbook)
prepare_loanbook_for_matching <- function(data, overwrite = NULL) {

  # check that input data has all pertinent columns
  crucial_data <- c(
    "name_direct_loantaker",
    "name_ultimate_parent",
    "id_direct_loantaker",
    "id_ultimate_parent",
    "sector"
  )
  r2dii.utils::check_crucial_names(data, crucial_data)

  # initialize empty overwrite data.frame with necessary columns
  init_overwrite <- function() {
    data.frame(
      level            = character(),
      id               = character(),
      name             = character(),
      sector           = character(),
      source           = character(),
      stringsAsFactors = F
    )
  }

  # load manual overwrite file, or initialize with empty overwrite file
  overwrite <- overwrite %||% init_overwrite()

  # check that input overwrite file has pertinent columns (note this comes after init_overwrite)
  crucial_overwrite <- c(
    "level",
    "id",
    "name",
    "sector",
    "source"
  )

  r2dii.utils::check_crucial_names(overwrite, crucial_overwrite)

  # extract all unique id & name pairs, with corresponding level and sector
  loanbook_match_values <-
    data %>% dplyr::select(
      .data$id_direct_loantaker,
      .data$name_direct_loantaker,
      .data$id_ultimate_parent,
      .data$name_ultimate_parent,
      .data$sector
    ) %>% tidyr::pivot_longer(
      cols = tidyr::starts_with("id_"),
      names_to = "level",
      names_prefix = "id_",
      values_to = "id"
    ) %>%
    dplyr::mutate(name =
             ifelse(.data$level == "direct_loantaker", .data$name_direct_loantaker, NA)) %>%
    dplyr::mutate(name =
             ifelse(.data$level == "ultimate_parent", .data$name_ultimate_parent, .data$name)) %>%
    dplyr::mutate(source = "loanbook") %>%
    dplyr::select(.data$level, .data$id, .data$name, .data$sector, .data$source) %>%
    dplyr::distinct()

  # join in manual values
  loanbook_match_values_overwrite <- dplyr::left_join(loanbook_match_values, overwrite, by=c("id", "level")) %>%
    dplyr::mutate(name = ifelse(is.na(.data$name.y), .data$name.x, .data$name.y),
           sector = ifelse(is.na(.data$sector.y), .data$sector.x, .data$sector.y),
           source = ifelse(is.na(.data$source.y), .data$source.x, "manual")) %>%
    dplyr::select(.data$level, .data$id, .data$name, .data$sector, .data$source)

  # simplify name
  loanbook_match_values_overwrite %>%
    dplyr::mutate(simplified_name = r2dii.match::replace_customer_name(.data$name))

}
