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

  # extract all unique id & name pairs, with corresponding level and sector
  loanbook_match_values <-
    loanbook_bridged %>% dplyr::select(
      id_direct_loantaker,
      name_direct_loantaker,
      id_ultimate_parent,
      name_ultimate_parent,
      sector
    ) %>% tidyr::pivot_longer(
      cols = starts_with("id_"),
      names_to = "level",
      names_prefix = "id_",
      values_to = "id"
    ) %>%
    mutate(name =
             ifelse(level == "direct_loantaker", name_direct_loantaker, NA)) %>%
    mutate(name =
             ifelse(level == "ultimate_parent", name_ultimate_parent, name)) %>%
    mutate(source = "loanbook") %>%
    select(level, id, name, sector, source) %>%
    distinct()

  # join in manual values
  loanbook_match_values_overwrite <- left_join(loanbook_match_values, overwrite, by=c("id", "level")) %>%
    mutate(name = ifelse(is.na(name.y), name.x, name.y),
           sector = ifelse(is.na(sector.y), sector.x, sector.y),
           source = ifelse(is.na(source.y), source.x, "manual")) %>%
    select(level, id, name, sector, source)

  # simplify name
  loanbook_match_values_overwrite %>%
    mutate(simplified_name = r2dii.match::simplifyName(name))

}
